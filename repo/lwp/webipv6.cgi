#!/usr/bin/haserl
<? title="View ipv6 Network"  /var/webconf/lib/preamble.sh  ?>
<!-- $Id -->

<? #  block copied from the viewipv6 cgi

t_head () {
        echo "<H1>$1</H1>"
	echo '<table border=0>'
        }
                        
t_foot () {
	echo '</table>'
        }
                                        
IP=/sbin/ip
# IFCFG=/sbin/ifconfig
# ROUTE=/sbin/route
# NETSTAT=/bin/netstat


showif()
{
    if [ -x $IP ]; then
        ipv6=0
	iface=""
	$IP addr show | { while read type rest; do
	    case $type in
	        *:) 
	            [ $ipv6 = 1 ] &&  echo -e "$iface"
	            iface="$type $rest"
	            ipv6=0
	            ;;
	        inet6)
	            ipv6=1
	            iface="$iface\n    $type $rest"
	            ;;
	        inet)
	            ;;
		*)
                    iface="$iface\n    $type $rest"
                    ;;
	    esac
        done;  [ $ipv6 = 1 ] && echo -e "$iface"; }
    else
        echo "Command not found"
    fi
}


showrte='echo Command not found ' 
[ -x $IP ] && showrte=`$IP -6 route show`


t_head "IPv6 Interfaces"
cat <<-/IFCONTENT
 <tr>
  <td><div><PRE>
$(showif)
  </PRE></div>
  </td>
 </tr>
/IFCONTENT
t_foot

t_head "IPv6 Routes"
cat <<- /ROUTECONTENT
 <tr>
  <td><div><PRE>
$showrte
  </PRE></div>
  </td>
 </tr>
/ROUTECONTENT
t_foot 

?>

<? /var/webconf/lib/footer.sh ?>
         
