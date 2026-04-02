#!/bin/bash

sleep 5

while true; do
  sleep 600 # 10 mins

  dunstify \
    -t 3200 \
    -i $HOME/.config/i3/scripts/eye-closed.svg \
    "Blink"
done
