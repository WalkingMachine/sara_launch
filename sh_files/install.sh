#!/bin/bash


# copy the specific terminal scripts for the automatic bringup stack
ln ressources/.devrc ~/.devrc

echo "Sara is now installed, but before being able to use Sara_total_bringup.sh. You need to open your gnome terminal and add a new profile named \"SARA\" and make it run this command:"
echo "/bin/bash --rcfile \"~/.devrc\""

