#!/bin/bash

# Get the hostname
hostname=$(hostname)

# Set the arguments based on the hostname
case $hostname in
    bane)
        arg1=9000
        ;;
    revan)
        arg1=9001
        ;;
    zannah)
        arg1=9002
        ;;
    *)
        echo "Unknown hostname: $hostname"
        exit 1
        ;;
esac

./create_template.sh "$hostname" "$arg1" 1
