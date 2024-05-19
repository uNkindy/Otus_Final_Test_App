#!/bin/bash

if [[ $(nmap -p 4000 $1 | sed -n 6p | cut -d ' ' -f2) == "open" ]]; then
        echo "First site ok!"
else
        echo "First site not ok"
        exit 5

fi

if [[ $(nmap -p 4000 $1 | sed -n 6p | cut -d ' ' -f2) == "open" ]]; then
        echo "Second site ok!"
else
        echo "Second site not ok"
        exit 5
fi
