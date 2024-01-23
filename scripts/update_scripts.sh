#!/bin/bash

# List of files to copy
files=(
    "./infra/"
    "./proxmox/create_template.sh"
    "./proxmox/wrapper.sh"
    "./proxmox/cron-notes.md"
)

# List of nodes to copy files to
nodes=(
    "23.0.0.5"
    "23.0.0.6"
    "23.0.0.7"
)

# Iterate over the nodes and files
for node in "${nodes[@]}"; do
    for file in "${files[@]}"; do
        # Copy the file to the node using scp
        scp -r "$file" "$node:"
    done
done
