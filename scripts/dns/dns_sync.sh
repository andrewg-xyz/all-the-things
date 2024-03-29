#!/bin/bash

export ORIGIN_URL=https://dns01.local.agreene.dev
export ORIGIN_USERNAME=<user>
export ORIGIN_PASSWORD=<secret>
export REPLICA_URL=https://dns02.local.agreene.dev
export REPLICA_USERNAME=<user>
export REPLICA_PASSWORD=<secret>

# run as daemon
adguardhome-sync run --cron "*/10 * * * *"