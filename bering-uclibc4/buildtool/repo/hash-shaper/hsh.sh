#!/bin/sh

. /etc/hsh.conf

#convert ip to integer
ip2int() {
    echo $@|$sed 's/\(\.\|\/\)/ /g'|$awk '{if ((NF==4)||(NF==5)) {OFMT = "%.0f"; 
	print $1*2^24+$2*2^16+$3*2^8+$4}}'
}

#convert integer to ip
int2ip() {
    echo $@|$awk '{if (NF==1) {s1=$1%2^24; s2=$1%2^16; OFMT = "%.0f";\
    print int($1/2^24)"."int(s1/2^16)"."int(s2/2^8)"."$1%256}}'
}

#get subnet addr for ip/mask
subnet() {
    echo $@|$sed 's/\(\.\|\/\)/ /g'|$awk '{if (NF==5) {ip=$1*2^24+$2*2^16+$3*2^8+$4; \
    subnet=ip-ip%2^(32-$5); s1=subnet%2^24; s2=subnet%2^16; OFMT = "%.0f";\
    print int(subnet/2^24)"."int(s1/2^16)"."int(s2/2^8)"."subnet%256"/"$5}}'
}

#get width of subnet
netwidth() {
    echo $@|$sed 's/\(\.\|\/\)/ /g'|$awk '{if (NF==5) {OFMT = "%.0f"; print 2^(32-$5)}}'
}

#get # of 256-byte subnets of network
subcnt() {
    echo $@|$sed 's/\(\.\|\/\)/ /g'|$awk '{if (NF==5) {width=2^(32-$5); i=(width%256>0); 
	OFMT = "%.0f"; print int(width/256)+i }}'
}

#return max of 2 ints
max() {
    echo $@|$awk '{OFMT = "%.0f"; if (NF==2) {if ($1>$2) {print $1} else {print $2}}}'
}

#print as hex
hex() {
    echo $@|$awk '{if (NF==1) {printf "%x", $1}}'
}

#sequence from $1 to $1+$2-1
lseq() {
    echo $@|$awk '{OFMT = "%.0f"; if (NF==2) {for (i=0;i<$2;i++) {print $1+i}}}'
}

#init device $1
initdev() {
    echo $UPDEVINIT|sh
    $tc q d root dev $1 2>/dev/null
    $tc q a root dev $1 handle 1: htb default 2
    $tc c a dev $1 parent 1: classid 1:1 htb rate $URATE ceil $UCEIL $UBURST prio 1 quantum 1514
    $tc c a dev $1 parent 1: classid 1:2 htb rate $URATE ceil $UCEIL $UBURST prio 2 quantum 1514
    $tc q a dev $1 parent 1:2 handle 2: sfq perturb 10 quantum 1514
    $tc f a dev $1 parent 1: prio 10 protocol ip u32
}

#add rule $1 with addr $2 for table $3 with default speed on device $4
addrule() {
    ar_id=$(($POOLWIDTH*($3+1)+$1))
    ar_id1=$(($RULECOUNT+$ar_id))
    ar_id2=$(($RULECOUNT*2+$ar_id))
    ar_h1=$(hex $1)
    $tc c a dev $4 parent 1:1 classid 1:$ar_id htb rate $URATE ceil $UCEIL $UBURST prio 1 quantum 1514
    $tc c a dev $4 parent 1:$ar_id classid 1:$ar_id1 htb rate $UHRATE ceil $UCEIL $UBURST prio 2 quantum 1514
    $tc c a dev $4 parent 1:$ar_id classid 1:$ar_id2 htb rate $UHRATE ceil $UCEIL $UBURST prio 1 quantum 1514
    $tc q a dev $4 parent 1:$ar_id1 handle $ar_id1: sfq perturb 10 quantum 1514
    $tc q a dev $4 parent 1:$ar_id2 handle $ar_id2: sfq perturb 10 quantum 1514
    $tc f a dev $4 parent 1: protocol ip prio 1 u32 ht $3:$ar_h1: \
	match ip tos 0x10 0xff flowid 1:$ar_id2
    $tc f a dev $4 parent 1: protocol ip prio 2 u32 ht $3:$ar_h1: \
	match ip protocol 6 0xff match u8 0x45 0xff at 0 match u16 0x0000 0xffc0 at 2 \
	match u8 0x10 0xff at 33 flowid 1:$ar_id2
    $tc f a dev $4 parent 1: protocol ip prio 3 u32 ht $3:$ar_h1: \
	match ip protocol 1 0xff flowid 1:$ar_id2
    $tc f a dev $4 parent 1: protocol ip prio 4 u32 ht $3:$ar_h1: match ip src $2 \
	flowid 1:$ar_id1
}

#set speed for rule $1 in table $2 with rate $3 kbit on device $4
setspeed() {
    ss_id=$(($POOLWIDTH*($2+1)+$1))
    ss_id1=$(($RULECOUNT+$ss_id))
    ss_id2=$(($RULECOUNT*2+$ss_id))
    ss_hr=$(($3/2))
    $tc c r dev $4 parent 1:1 classid 1:$ss_id htb rate ${3}kbit $UBURST prio 1 quantum 1514
    $tc c r dev $4 parent 1:$ss_id classid 1:$ss_id1 htb rate ${ss_hr}kbit ceil ${3}kbit $UBURST prio 2 quantum 1514
    $tc c r dev $4 parent 1:$ss_id classid 1:$ss_id2 htb rate ${ss_hr}kbit ceil ${3}kbit $UBURST prio 1 quantum 1514
}

#fill table for subnet addr $1, device $2
addtable() {
    nwidth=$(netwidth $1)
    $tc f a dev $2 parent 1:1 prio 10 handle $tctr: protocol ip u32 divisor $nwidth
    $tc f a dev $2 parent 1: protocol ip prio 10 u32 ht 800:: \
        match ip src $(subnet $1) \
        hashkey mask 0x$(hex $(($nwidth-1))) at 12 \
	link $tctr:
    at_t=0
    for at_i in $(lseq $(ip2int $1) $nwidth); do
	addrule $at_t $(int2ip $at_i) $tctr $2
	at_t=$(($at_t+1))
    done    
}

#divide network $1 by subnets
divnet() {
    for dn_net in $@; do
	dn_count=$(subcnt $dn_net)
	if [ $dn_count -gt 1 ]; then
	    dn_subnet=$(ip2int $(subnet $dn_net))
	    for dn_i in $(lseq 0 $dn_count); do
		echo $(int2ip $((dn_subnet+dn_i*256)))/24
	    done
	else
	    echo $dn_net
	fi
    done
}

#is ip $2 in subnet $1?
chkip() {
    echo $(ip2int $1) $(ip2int $2) $(netwidth $1)|awk '{print (($2>=$1)&&($2<=$1+$3))}'
}

POOLWIDTH=0
NPOOLS=$(divnet $POOLS)
NETCOUNT=$(echo $NPOOLS|wc -w)
for i in $NPOOLS; do
    POOLWIDTH=$(max $POOLWIDTH $(netwidth $i))    
done
RULECOUNT=$(($POOLWIDTH*$NETCOUNT))

tctr=1
case "$1" in
    init)
	for iface in $UPDEVS; do
	    initdev $iface
	    tctr=1
	    for i in $NPOOLS; do
		addtable $i $iface
		tctr=$(($tctr+1))
	    done
	done;;
    set)
	for i in $NPOOLS; do
	    if [ $(chkip $i $2) -eq 1 ]; then
		rulenum=$(($(ip2int $2)-$(ip2int $i)))
		if [ -z "$4" ]; then
		    for iface in $UPDEVS; do
			setspeed $rulenum $tctr $3 $iface
		    done
		else
		    setspeed $rulenum $tctr $3 $4
		fi
		exit 0
	    fi
	    tctr=$(($tctr+1))
	done
	echo "This IP isn't in pool!"
        exit 1;;
    cstat)
	for i in $NPOOLS; do
	    if [ $(chkip $i $2) -eq 1 ]; then
		cl1=$(($POOLWIDTH*($tctr+1)+$(ip2int $2)-$(ip2int $i)))
		if [ -z "$3" ]; then
		    for iface in $UPDEVS; do
			echo "Interface $iface"
			$tc -s c s dev $iface|grep -A 4 " 1:$cl1 "
		    done;
		else
		    $tc -s c s dev $3|grep -A 4 " 1:$cl1 "
		fi
		exit 0
	    fi
	    tctr=$(($tctr+1))
	done
	echo "This IP isn't in pool!"
	exit 1;;
    stop)
	echo $UPDEVSTOP|sh;;
    *)
	echo Usage: "$0 (init|stop|set <ip> <speed in kbit> [iface]|cstat <ip> [iface])";;
esac


