# Alias de WM
alias NEWICON='gnome-desktop-item-edit --create-new ~/LauncherIcons ; nautilus ~/LauncherIcons'
alias CATKIN_MAKE='cd ~/sara_ws; catkin_make; cd -'

if [ -n "$ZSH_VERSION" ]; then
    alias SOURCERC='source ~/.zshrc'
    alias RC='atom ~/.zshrc 2> /dev/null'
elif [ -n "$BASH_VERSION" ]; then
    alias SOURCERC='source ~/.bashrc'
    alias RC='atom ~/.bashrc 2> /dev/null'
fi

alias SARARC='atom ~/sara_ws/src/sara_launch/sh_files/sararc.sh 2> /dev/null'

# Alias de Sara
alias FLEXBE='SOURCERC; roslaunch flexbe_app flexbe_full.launch'
alias FLEXBEAPP='SOURCERC; roslaunch flexbe_app flexbe_ocs.launch'
alias FLEXBEENGINE='SOURCERC; roslaunch flexbe_onboard behavior_onboard.launch'
alias FLEXBERUNBEHAVIOR='SOURCERC; rosrun flexbe_widget be_launcher -b'
alias START_SARA='SOURCERC; ~/sara_ws/src/sara_launch/sh_files/Sara_total_bringup.sh'
alias TELEOP='SOURCERC; roslaunch sara_teleop sara_teleop.launch'
alias JETSON='ssh nvidia@sara-jetson1'

export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export OPENPOSE_HOME=~/openpose

# ros related sourcing
if [ -n "$ZSH_VERSION" ]; then
    source /opt/ros/kinetic/setup.zsh
    source ~/sara_ws/devel/setup.zsh
elif [ -n "$BASH_VERSION" ]; then
    source /opt/ros/kinetic/setup.bash
    source ~/sara_ws/devel/setup.bash
fi

#IP of roscore in the local router
# export ROS_IP=192.168.0.250
# export ROS_MASTER_URI=http://192.168.0.250:11311/

# . /home/walking/torch/install/bin/torch-activate

export GOOGLE_APPLICATION_CREDENTIALS="/home/walking/project.json"
