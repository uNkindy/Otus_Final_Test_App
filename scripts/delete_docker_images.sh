#!/bin/bash

docker ps | cut -d ' ' -f1 | while read container_id
do
        if [[ $container_id != "9b59d6bf5d07" ]]; then
                if [[ $container_id == "CONTAINER" ]]; then
                        continue
                fi
                docker stop $container_id
        else
                echo "It's GitLab container!"
        fi
done