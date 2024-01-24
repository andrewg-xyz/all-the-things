node_id=
cpus=4
memory=16384
disk0=25G
disk1=100
ip_short=

debug=false

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

usage() {
    echo "Usage: create_node.sh [-n node_id] [-c cpus] [-m memory] [-d disk0] [-i ip_short] [-D]"
    echo "Options:"
    echo "  -n node_id    : Node ID"
    echo "  -c cpus       : Number of CPUs (default: 4)"
    echo "  -m memory     : Memory size in MB (default: 16384)"
    echo "  -d disk0      : Disk0 size (default: 25G)"
    echo "  -i ip_short   : IP address last octet"
    echo "  -D            : Enable debug mode"
}

while getopts ":n:c:m:d:i:D" opt; do
    case $opt in
    n)
        node_id=$OPTARG
        ;;
    c)
        cpus=$OPTARG
        ;;
    m)
        memory=$OPTARG
        ;;
    d)
        disk0=$OPTARG
        ;;
    i)
        ip_short=$OPTARG
        ;;
    D)
        debug=true
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1
        ;;
    esac
done

if [[ -z $node_id ]]; then
    echo "Node ID is required"
    usage
    exit 1
fi

if [[ -z $ip_short ]]; then
    echo "IP address last octet is required"
    usage
    exit 1
fi

CMD="qm "
if $debug; then
    echo "Debug mode enabled"
    CMD="echo qm "
fi

half_cpus=$(expr $cpus / 2)

if [[ $(hostname) == "bane" ]]; then
    host=9000
elif [[ $(hostname) == "revan" ]]; then
    host=9001
elif [[ $(hostname) == "zannah" ]]; then
    host=9002
elif [[ $debug ]]; then
    host=DEBUG_HOST
else
    echo "Unknown hostname"
    exit 1
fi

$CMD clone $host "$node_id" --name node"$node_id"
# Can't seem to shake this error
#   unable to parse directory volume name '/root/infra/node/cloud-init.yaml'
# $CMD set "$node_id" --cicustom "user=local:$SCRIPT_PATH/cloud-init.yaml"
share_the_load=$(expr $cpus / 2)

$CMD set "$node_id" --sockets "$share_the_load" --cores "$share_the_load" --memory "$memory" --cpu x86-64-v2
$CMD resize "$node_id" scsi0 $disk0
$CMD set "$node_id" --scsi1 local-lvm:$disk1
$CMD set "$node_id" --net0 virtio,bridge=vmbr0
$CMD set "$node_id" --ipconfig0 "ip=23.0.0.$ip_short/32,gw=23.0.0.1"
$CMD start "$node_id"
