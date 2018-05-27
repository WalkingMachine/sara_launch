
# Alias de Sara
alias FLEXBE='roslaunch flexbe_onboard behavior_onboard.launch'
alias FLEXBEWIDGET='roslaunch flexbe_widget behavior_ocs.launch'
alias FLEXBERUNBEHAVIOR='rosrun flexbe_widget be_launcher -b'
alias START_SARA='~/sara_ws/src/sara_launch/sh_files/Sara_total_bringup.sh'
alias TELEOP='roslaunch sara_teleop sara_teleop.launch'
alias WONDERLAND='cd ~/sara_ws/wonderland/ ; python manage.py runserver ; cd -'
alias LU4R='cd ~/lu4r-0.2.1/lu4r-0.2.1/ ; java -Xmx1G -jar lu4r-server-0.2.1.jar simple amr en 9001 ; cd -'
alias CATKIN_MAKE='cd ~/sara_ws; catkin_make; cd -'
alias SETNETWORK='sudo route del default gw 192.168.1.254'
alias JETSON='ssh nvidia@sara-jetson1'

# Alias de WM
alias NEWICON='gnome-desktop-item-edit --create-new ~/LauncherIcons ; nautilus ~/LauncherIcons'
alias BASHRC='gedit ~/.bashrc 2> /dev/null'
alias SOURCEBASHRC='source ~/.bashrc'

export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export OPENPOSE_HOME=~/openpose
# ros related sourcing

source /opt/ros/kinetic/setup.bash
source ~/sara_ws/devel/setup.bash

#IP of roscore in the local router
export ROS_IP=192.168.0.250
export ROS_MASTER_URI=http://192.168.0.250:11311/
#export ROS_MASTER_URI=http://127.0.0.1:11311/

#Test Jetson
#export ROS_MASTER_URI=http://192.168.0.252:11311/

. /home/walking/torch/install/bin/torch-activate

export GOOGLE_APPLICATION_CREDENTIALS="/home/walking/project.json"