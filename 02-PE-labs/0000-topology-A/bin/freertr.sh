#! /bin/sh

iflag=false
rflag=false
FREERTR_INTF_LIST=""
FREERTR_HOSTNAME="freertr"
FREERTR_HOME=$(pwd)
FREERTR_BASE_DIR="$FREERTR_HOME/run/$FREERTR_HOSTNAME"
FREERTR_INSTALL_DIR="$FREERTR_HOME/bin/"

usage(){
	echo "Usage: `basename $0` -i <intf/port1/port2> -r <freertr-hostname> -h for help";
	echo "Example: $0 -i \"eth0/22705/22706 eth1/20010/20011\" -r freertr1"
	exit 1
}

bindintf () {
    FREERTR_INTF_LIST=$1

    echo "--- DECLARING FREERTR INTERFACE RAWINT (FORWARDING PLANE) ---";
    IFS=" ";
    for FREERTR_INTF in $FREERTR_INTF_LIST;
      do
        IFS=/;
        set $FREERTR_INTF;
        ifconfig $1 multicast allmulti promisc mtu 1500 up
        ethtool -K $1 rx off
        ethtool -K $1 tx off
        ethtool -K $1 sg off
        ethtool -K $1 tso off
        ethtool -K $1 ufo off
        ethtool -K $1 gso off
        ethtool -K $1 gro off
        ethtool -K $1 lro off
        ethtool -K $1 rxvlan off
        ethtool -K $1 txvlan off
        ethtool -K $1 ntuple off
        ethtool -K $1 rxhash off
        ethtool --set-eee $1 eee off

        #start-stop-daemon -S -b -x "${FREERTR_INSTALL_DIR}/rawInt.bin" $1 $3 127.0.0.1 $2 127.0.0.1;
        start-stop-daemon -S -b --name $FREERTR_HOSTNAME -x "${FREERTR_INSTALL_DIR}/pcapInt.bin" $1 $2 127.0.0.1 $3 127.0.0.1;
      done
}

start_freertr () {
  FREERTR_BASE_DIR=$1 
  FREERTR_HOSTNAME=$2 
  cd "${FREERTR_BASE_DIR}"
  java -jar "${FREERTR_INSTALL_DIR}/rtr.jar" routers "${FREERTR_BASE_DIR}/${FREERTR_HOSTNAME}-hw.txt" "${FREERTR_BASE_DIR}/${FREERTR_HOSTNAME}-sw.txt" </dev/null &
}



if ( ! getopts ":hi:r:" opt); then
        usage
	exit $E_OPTERROR;
fi

while getopts ":hi:r:" opt;do
case $opt in
  i)
    FREERTR_INTF_LIST=$OPTARG
    iflag=true 
  ;;
  r)
    FREERTR_HOSTNAME=$OPTARG
    rflag=true 
  ;;
  \?)
     echo "Option not supported." >&2
     usage
     exit 1
  ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    usage
    exit 1
  ;;  
  h|*)
   usage
   exit 1 
  ;;
  esac
done

if $iflag && $rflag ;
then
   FREERTR_BASE_DIR=$FREERTR_HOME/run/$FREERTR_HOSTNAME
   bindintf "${FREERTR_INTF_LIST}" "${FREERTR_BASE_DIR}"
   start_freertr "${FREERTR_BASE_DIR}" ${FREERTR_HOSTNAME}
else
   if ! $iflag; then echo "[-i] freertr interface list missing" 
   usage
   fi
   if ! $rflag; then echo "[-r] router hostname missing" 
   usage
   fi
fi
