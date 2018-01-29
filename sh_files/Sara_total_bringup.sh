#!/bin/bash


VISION=false
SPEECH=false
HELP=false
STATEMACHINE=false
TELE=false
NAV=false
GENIALE=false
RVIZ=false
while getopts "asvhtfngz" opt; do
  case "$opt" in
    a)
        ALL=true
        SPEECH=true
        VISION=true
        TELEOP=true
        NAV=true
        STATEMACHINE=true ;;
    n) NAV=true ;;
    s) SPEECH=true ;;
    v) VISION=true ;;
    t) TELE=true ;;
    f) STATEMACHINE=true ;;
    g) GENIALE=true ;;
    z) RVIZ=true ;;
    h)
        echo "SYNOPSIS:"
        echo " Sara_total_bringup [options]"
        echo "OPTIONS:"
        echo " -a  activate all options"
        echo " -h  show this help message"
        echo " -f  activate flexbe state machine engine"
        echo " -n  activate autonaumous navigation"
        echo " -s  activate speech to text"
        echo " -t  activate teleoperation"
        echo " -g  geniale node"
        echo " -v  activate vision stack"
        echo " -z  start rviz"
        HELP=true  ;;
  esac
done
shift $(( OPTIND - 1 ))

if ! $HELP
then

    echo "Starting roscore"
    gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roscore ; echo -e '$(tput setaf 1)roscore just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    sleep 3

    echo "Launching ui helper"
    gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; rosrun sara_ui sara_ui_helper; echo -e '$(tput setaf 1)UI helper just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"

    sleep 3

    echo "Bringup the hardware"
    gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch sara_launch sara_bringup.launch; echo -e '$(tput setaf 1)Bringup just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"

    echo "Launching Wonderland"
    gnome-terminal --profile=Bringup -x bash -c "cd ~/sara_ws/wonderland/ ; python manage.py runserver; echo -e '$(tput setaf 1)wonderland just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"

    sleep 3

    echo "Launching flexbe core"
    gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch flexbe_onboard behavior_onboard.launch; echo -e '$(tput setaf 1)flexbe onboard just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"


    if $SPEECH
    then
        echo "Launching google speech to text"
        gnome-terminal --profile=Voice -x bash -c "cd ~ ; source .bashrc ; roslaunch lab_ros_speech_to_text google_tts_FR.launch; echo -e '$(tput setaf 1)lab_ros_stt just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
        echo "Launching speech splitter"
        gnome-terminal --profile=Voice -x bash -c "source .bashrc ; roslaunch wm_speech_splitter sara_speech.launch; echo -e '$(tput setaf 1)Speech splitter just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
        echo "Launching lu4r"
        gnome-terminal --profile=Voice -x bash -c "cd ~/lu4r-0.2.1/lu4r-0.2.1/ ; java -Xmx1G -jar lu4r-server-0.2.1.jar simple amr en 9001; echo -e '$(tput setaf 1)lu4r just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
        # echo "echo sara_command"
        # gnome-terminal --profile=Voice -x bash -c "source .bashrc ; rostopic echo /sara_command"
    fi

    if $VISION
    then
        echo "Launching darknet"
        gnome-terminal --profile=Vision -x bash -c "source .bashrc ; roslaunch darknet_ros darknet_ros.launch; echo -e '$(tput setaf 1)darknet just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
        echo "Launching frame to box"
        gnome-terminal --profile=Vision -x bash -c "source .bashrc ; roslaunch wm_frame_to_box wm_frame_to_box.launch; echo -e '$(tput setaf 1)frame_to_box just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi

    if $NAV
    then
        echo "Launching navigation"
        gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch sara_navigation move_base_amcl.launch; echo -e '$(tput setaf 1)move_base just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi


    if $STATEMACHINE
    then
        echo "Launching flexbe widget"
        gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch flexbe_widget behavior_ocs.launch; echo -e '$(tput setaf 1)flexbe widget just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi

    if $RVIZ
    then
        echo "Launching rviz"
        gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; rviz; echo -e '$(tput setaf 1)rviz just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi

    if $GENIALE
    then
        echo "Launching geniale nodes"
        gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; rosrun robotiq_c_model_control CModelTcpNode.py 192.168.1.11; echo -e '$(tput setaf 1)geniale just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi

    sleep 6
    if $TELE
    then
        echo "Launching teleop"
        gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch sara_teleop sara_teleop.launch; echo -e '$(tput setaf 1)teleop just died$(tput setaf 9)' >> $(tty); echo -e '$(tput setaf 1)$(tput setab 7)Im dead'; sleep 20"
    fi

fi
