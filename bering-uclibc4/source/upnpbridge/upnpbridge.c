/******
 *
 *  U P N P B R I D G E . C
 *
 ******/

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/param.h>
#include <net/if.h>
#include <malloc.h>

struct in_addr ssdpaddr;

#define SSDPADDR "239.255.255.250"
#define SSDPPORT 1900

//#define debugprint 1
#define debugprint 0

#define dbgprintf if (debugprint) fprintf
#define ERRPRINT(rv) if (rv < 0) dbgprintf(stderr, "Errno: %d, %s\n", errno, strerror(errno))

typedef struct ll2WaySocket_t {
    struct ll2WaySocket_t *next;
    int rxs, txs;
    char *rxn, *txn;
} ll2WaySocket_t;

ll2WaySocket_t *lls = NULL;

pid_t pid, sid;

unsigned long
get_ip_by_spec(char *spec)
{
    int fd;
    int badlen;
    struct ifreq ifr;
    struct in_addr addr;

    /* If the string badlen chars long, it's not a valid */
    /* IP address or interface name. An IPv4 address is */
    /* at max 15 characters long. */
    badlen = MAX(IF_NAMESIZE, 16);
    if (strnlen(spec, badlen) < badlen) {
        fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
        if (fd < 0)
            return 0L;        /* internal error */
        memset(&ifr, 0, sizeof(struct ifreq));
        strcpy(ifr.ifr_name, spec);
        ifr.ifr_addr.sa_family = AF_INET;
        if (ioctl(fd, SIOCGIFADDR, &ifr) >= 0) {
            close(fd);
            return (((struct sockaddr_in *) &ifr.ifr_addr)->sin_addr.s_addr);
        }
        close(fd);
    }

    return 0L;
}


void initialise(int argc, char *argv[])
{
    int retval;
    int argn;
    struct ll2WaySocket_t **cplls = &lls;

    ssdpaddr.s_addr = inet_addr(SSDPADDR);

    if (argc < 3)
    {
        printf("UPnPbridge bridges SSDP datagrams between interfaces.\nAt least 2 interfaces must be specified on the command line.\n\nUsage: %s if1 if2 [...]\n", argv[0]);
        exit(1);
    }
    else for (argn=1; argn<argc; argn++)
    {
        struct in_addr itfaddr;

        dbgprintf(stderr, "\nProcessing argv[%d]=%s\n", argn, argv[argn]);

        if (0L == (itfaddr.s_addr = get_ip_by_spec(argv[argn])))
        {
            fprintf(stderr, "%s: Unknown interface name (%s)\n", argv[0], argv[argn]);
            exit(1);
        }

        dbgprintf(stderr, "Interface address 0x%lx; ", itfaddr.s_addr);

        if (NULL == (*cplls = malloc(sizeof(ll2WaySocket_t))))
        {
            fprintf(stderr, "%s: Memory allocation error\n", argv[0]);
            exit(1);
        }

        memset(*cplls, 0, sizeof(ll2WaySocket_t));
        (**cplls).rxs = socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
        (**cplls).txs = socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
        dbgprintf(stderr, "Created rxs(%d) and txs(%d); ", (**cplls).rxs, (**cplls).txs);

        (**cplls).rxn = (**cplls).txn = argv[argn];

        {
            u_int hi = 1;

            retval = setsockopt((**cplls).rxs, IPPROTO_IP, IP_HDRINCL, &hi, sizeof(hi));
            dbgprintf(stderr, "setsockopt(%d, IP, HDRINCL, [%d], %d)=%d; ",
                      (**cplls).rxs, hi, sizeof(hi), retval);
            ERRPRINT(retval);

            retval = setsockopt((**cplls).txs, IPPROTO_IP, IP_HDRINCL, &hi, sizeof(hi));
            dbgprintf(stderr, "setsockopt(%d, IP, HDRINCL, [%d], %d)=%d; ",
                      (**cplls).txs, hi, sizeof(hi), retval);
            ERRPRINT(retval);
        }
        {
            u_int on = 1;

            retval = setsockopt((**cplls).rxs, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
            dbgprintf(stderr, "setsockopt(%d, SOCK, REUS, [%d], %d)=%d; ",
                      (**cplls).rxs, on, sizeof(on), retval);
            ERRPRINT(retval);

            retval = setsockopt((**cplls).txs, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
            dbgprintf(stderr, "setsockopt(%d, SOCK, REUS, [%d], %d)=%d; ",
                      (**cplls).txs, on, sizeof(on), retval);
            ERRPRINT(retval);
        }
        {
            struct sockaddr_in sa;

            sa.sin_family = AF_INET;
            sa.sin_addr.s_addr = ssdpaddr.s_addr;
            sa.sin_port = htons(SSDPPORT);

            retval = bind((**cplls).rxs, (struct sockaddr *)&sa, sizeof(sa));
            dbgprintf(stderr, "bind(%d, {%d, 0x%lx, %d}, %d)=%d; ",
                      (**cplls).rxs, AF_INET, sa.sin_addr.s_addr, SSDPPORT, sizeof(sa), retval);
            ERRPRINT(retval);

            retval = bind((**cplls).txs, (struct sockaddr *)&sa, sizeof(sa));
            dbgprintf(stderr, "bind(%d, {%d, 0x%lx, %d}, %d)=%d; ",
                      (**cplls).txs, AF_INET, sa.sin_addr.s_addr, SSDPPORT, sizeof(sa), retval);
            ERRPRINT(retval);
        }
        {
            u_int loop = 0;

            retval = setsockopt((**cplls).txs, IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop));
            dbgprintf(stderr, "setsockopt(%d, IP, MCAST_LOOP, [%d], %d)=%d; ",
                      (**cplls).txs, loop, sizeof(loop), retval);
            ERRPRINT(retval);
        }
        {
            u_int ttl = 4;

            retval = setsockopt((**cplls).txs, SOL_IP, IP_MULTICAST_TTL, &ttl, sizeof(ttl));
            dbgprintf(stderr, "setsockopt(%d, IP, TTL, [%d], %d)=%d; ",
                      (**cplls).txs, ttl, sizeof(ttl), retval);
            ERRPRINT(retval);
        }
        {
            retval = setsockopt((**cplls).txs, SOL_IP, IP_MULTICAST_IF, &itfaddr, sizeof(itfaddr));
            dbgprintf(stderr, "setsockopt(%d, IP, MCAST_IF, 0x%lx, %d)=%d; ",
                      (**cplls).txs, itfaddr.s_addr, sizeof(itfaddr), retval);
            ERRPRINT(retval);
        }
        {
            struct ip_mreqn membership;

            membership.imr_multiaddr.s_addr = ssdpaddr.s_addr;
            membership.imr_address = itfaddr;
            membership.imr_ifindex = if_nametoindex((**cplls).rxn);

            retval = setsockopt((**cplls).rxs, SOL_IP, IP_ADD_MEMBERSHIP, &membership, sizeof(membership));
            dbgprintf(stderr, "setsockopt(%d, IP, ADD_MEM, {{0x%lx, 0x%lx, %d}, %d)=%d; ",
                      (**cplls).rxs,
                      membership.imr_multiaddr.s_addr, membership.imr_address.s_addr,
                      membership.imr_ifindex, sizeof(membership), retval);
            ERRPRINT(retval);

            retval = setsockopt((**cplls).rxs, SOL_SOCKET, SO_BINDTODEVICE, (**cplls).rxn, 1+strlen((**cplls).rxn));
            dbgprintf(stderr, "setsockopt(%d, SOCK, BIND2DEV, %s, %d)=%d; ",
                      (**cplls).rxs, (**cplls).rxn, 1+strlen((**cplls).rxn), retval);
            ERRPRINT(retval);
        }

        cplls = &((**cplls).next);

        dbgprintf(stderr, "\n\n");
    }

    if (!debugprint)
    {
        pid = fork();
        if (pid < 0) exit(1);
        if (pid > 0) exit(0);
        umask(0);
        sid = setsid();
        if (sid < 0) exit(1);
        close(stdin);
        close(stdout);
        close(stderr);
    }
}

void doTheBusiness()
{
    struct sockaddr_in sa;
    ll2WaySocket_t **cplls, **iplls, **oplls;

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = ssdpaddr.s_addr;
    sa.sin_port = htons(SSDPPORT);

    while (1)
    {
        fd_set rfds;
        struct timeval tv;
        int retval, maxs;

        FD_ZERO(&rfds);

        for (cplls = &lls, maxs = 0; NULL != *cplls; cplls = &((**cplls).next))
        {
            FD_SET((**cplls).rxs, &rfds);
            if ((**cplls).rxs > maxs) maxs = (**cplls).rxs;
        }

        tv.tv_sec = 1000; tv.tv_usec=0;

        retval = select(1+maxs, &rfds, NULL, NULL, &tv);

        if (retval)
        {
            for (iplls = &lls; NULL != *iplls; iplls = &((**iplls).next))
            {
                if (FD_ISSET((**iplls).rxs, &rfds))
                {
                    u_char buf[2048];
                    struct sockaddr from;
                    socklen_t fromlen=0;
                    int recvlen;

                    memset(buf, 0, sizeof(buf));

                    recvlen = recvfrom((**iplls).rxs, buf, sizeof(buf)-1, 0, &from, &fromlen);

                    dbgprintf(stderr, "Recv %s, size=%d, from={%d,0x%lx,0x%x}, fromlen=%d\n",
                              (**iplls).rxn, recvlen,
                              ((struct sockaddr_in *)&from)->sin_family,
                              ((struct sockaddr_in *)&from)->sin_addr.s_addr,
                              ((struct sockaddr_in *)&from)->sin_port, fromlen);

                    if (recvlen > 0)
                    for (oplls = &lls; NULL != *oplls; oplls = &((**oplls).next))
                    if ((**iplls).rxs != (**oplls).rxs)
                    {
                        retval = sendto((**oplls).txs, buf, recvlen, 0, &sa, sizeof(sa));
                        if (retval != recvlen)
                            dbgprintf(stderr, "sendto %s error %d\n", (**oplls).txn, retval);
                        ERRPRINT(retval);
                    }
                }
            }
        }
    }
}

void deinitialise()
{
}

int main(int argc, char *argv[])
{
    initialise(argc, argv);
    doTheBusiness();
    deinitialise();
    exit(0);
}
