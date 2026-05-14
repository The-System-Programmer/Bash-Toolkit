#!/bin/bash
while true
do
    ping -c 1 8.8.8.8 > /dev/null

    if [ $? -eq 0 ]; then
        echo "$(date): Internet OK"
    else
        echo "$(date): Internet Down"
    fi
    sleep 10
done
