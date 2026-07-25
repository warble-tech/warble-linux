#!/bin/bash

# Only run for interactive shells
if [ -n "$PS1" ] && [ -z "$WARBLE_TUTORIAL_SEEN" ]; then
    export WARBLE_TUTORIAL_SEEN=1
    
    dialog --backtitle "Warble-Linux Sandbox OS" \
           --title "Welcome to Warble-Linux" \
           --msgbox "Welcome to the Warble-Linux Sandbox OS!\n\nThis is a privacy-focused, ephemeral learning environment.\nAll your data is currently stored in RAM and will be destroyed upon reboot." 10 60
           
    dialog --backtitle "Warble-Linux Sandbox OS" \
           --title "Included Tools" \
           --msgbox "You have access to the following tools:\n- Terminator (Your default terminal)\n- Neovim (Pre-configured for Dev)\n- K3s (Local Kubernetes)\n- Firefox (Restricted to localhost)\n- Rust, Go, Python, Node.js" 12 60
           
    dialog --backtitle "Warble-Linux Sandbox OS" \
           --title "DevOps Exercises" \
           --yesno "Would you like to open the DevOps exercises repository now?" 8 60
           
    response=$?
    if [ $response -eq 0 ]; then
        cd ~/devops-exercises || echo "Repo not found"
        clear
        echo "You are now in the devops-exercises directory. Happy learning!"
    else
        clear
        echo "Enjoy your secure sandboxed environment!"
    fi
fi
