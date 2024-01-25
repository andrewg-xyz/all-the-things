nodes=5
ip_start=30
vmid_start=200

for ((i = 0; i < nodes; i++)); do
    vmid=$(($vmid_start + i))
    if [[ $1 == "-d" ]]; then
        echo "Destroying node $vmid"
        qm stop $vmid
        qm destroy $vmid
        continue # Break out of the current iteration
    fi

    ip=$((ip_start + i))
    msg="$((i + 1)): IP $ip"

    remainder=$((ip % 2))
    if [[ $remainder -eq 1 ]]; then
        if [[ $(hostname) == "bane" ]]; then
            echo "bane: $msg"
            ./node/create_node.sh -n $vmid -i $ip
        fi
    else
        if [[ $(hostname) == "revan" ]]; then
            echo "revan: $msg"
            ./node/create_node.sh -n $vmid -i $ip
        fi
    fi
done
