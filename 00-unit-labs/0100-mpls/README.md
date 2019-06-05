# Lab diagram

![Lab diagram](https://github.com/frederic-loui/RARE/raw/master/resources/0100-mpls.png)

# TL;DR

```
# Build topology & compile p4 program
./build.sh
```

```
# check h1 cannot ping h4 nd vice-versa (no table rules yet ;-) )

# [h1-->h4]
mininet> h1 ping h4
PING 10.0.4.4 (10.0.4.4) 56(84) bytes of data.
^C
--- 10.0.4.4 ping statistics ---
12 packets transmitted, 0 received, 100% packet loss, time 11087ms

# [h4-->h1]
mininet> h4 ping h1
PING 10.0.1.1 (10.0.1.1) 56(84) bytes of data.
^C
--- 10.0.1.1 ping statistics ---
8 packets transmitted, 0 received, 100% packet loss, time 7056ms
```

```
# Launch p4runtime controller and inject rules
make controller
```

```
# relaunch ping from [h1-->h4] and [h4 --> h1]
mininet> h1 ping -c 5 h4
PING 10.0.4.4 (10.0.4.4) 56(84) bytes of data.
64 bytes from 10.0.4.4: icmp_seq=1 ttl=64 time=15.4 ms
64 bytes from 10.0.4.4: icmp_seq=2 ttl=64 time=11.9 ms
64 bytes from 10.0.4.4: icmp_seq=3 ttl=64 time=12.0 ms
64 bytes from 10.0.4.4: icmp_seq=4 ttl=64 time=12.0 ms
64 bytes from 10.0.4.4: icmp_seq=5 ttl=64 time=12.1 ms

--- 10.0.4.4 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4004ms
rtt min/avg/max/mdev = 11.956/12.730/15.484/1.378 ms
mininet> h4 ping -c 5 h1 
PING 10.0.1.1 (10.0.1.1) 56(84) bytes of data.
64 bytes from 10.0.1.1: icmp_seq=1 ttl=64 time=11.1 ms
64 bytes from 10.0.1.1: icmp_seq=2 ttl=64 time=11.4 ms
64 bytes from 10.0.1.1: icmp_seq=3 ttl=64 time=11.3 ms
64 bytes from 10.0.1.1: icmp_seq=4 ttl=64 time=11.6 ms
64 bytes from 10.0.1.1: icmp_seq=5 ttl=64 time=10.6 ms

--- 10.0.1.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4005ms
rtt min/avg/max/mdev = 10.674/11.263/11.699/0.353 ms
mininet> 
```

```
# Last but not least ! Clean lab 
# otherwise it will conflict with other examples 
./clean.sh

```
