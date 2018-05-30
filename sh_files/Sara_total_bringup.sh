#!/bin/bash


VISION=false
SPEECH=false
HELP=false
STATEMACHINE=false
TELEOP=false
NAV=false
GENIALE=false
RVIZ=false
JET=true
LANGUE="en-US"

while getopts "asvhtfJngzl:" opt; do

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
    J) JET=false ;;
    t) TELEOP=true ;;
    f) STATEMACHINE=true ;;
    g) GENIALE=true ;;
    z) RVIZ=true ;;
    l) LANGUE=$OPTARG ;;
    h)
        echo 'SYNOPSIS:'
        echo ' Sara_total_bringup [options]'
        echo 'OPTIONS:'
        echo ' -a  activate all options'
        echo ' -f  activate flexbe state machine widget'
        echo ' -h  show this help message'
        echo ' -J  do not use the jetson'
        echo ' -n  activate autonaumous navigation'
        echo ' -s  activate speech to text'
        echo ' -t  activate teleoperation'
        echo ' -v  activate vision stack'
        echo ' -z  start rviz'
        HELP=true  ;;
  esac
done
shift $(( OPTIND - 1 ))



# Function that can kill all orbital terminals
function cleanup {
    echo 'killing all processes'
    for f in $(cat ~/tempPID)
    do
        kill -s 9 $f
    done
    echo > ~/tempPID
}
trap cleanup EXIT




# Export the variable that will contain the command for each orbital terminals
export SARACMD



if ! $HELP
then

    # Loop forever
    while true
    do


        echo 'waiting for power'
        while [ ! -r /dev/dynamixel ] || [ ! -r /dev/robotiq ] || [ ! -r /dev/drive1 ] || [ ! -r /dev/kinova  ]
        do
            sleep 1
        done
        echo > tempPID


        echo 'Starting roscore'
        SARACMD='roscore'
        SARACMD+='; echo -e "$(tput setaf 1)roscore just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA
        sleep 2


        echo "Setting voice to $LANGUE"
        rosparam set /langue $LANGUE

#        rosparam set use_sim_time true
#        date --set="$ssh nvidia@sara-jetson1"

        echo 'Bringup the hardware'
        SARACMD='roslaunch sara_launch sara_bringup.launch'
        SARACMD+='; echo -e "$(tput setaf 1)sara_bringup just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA

        sleep 1


        if ${JET}
        then

            echo 'Starting jetson'
            SARACMD='while [ ! $(ssh -t -t nvidia@sara-jetson1 "echo ok" ) ] ; do echo Still waiting for jetson ; sleep 1; done'
            SARACMD+="; ssh -t -t nvidia@sara-jetson1 'cd /home/nvidia ; roslaunch sara_launch jetson.launch'"
            SARACMD+='; echo -e "$(tput setaf 1)jetson just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA
        fi


#        echo 'Starting soundboard'
#        echo ""
#        SARACMD+='; echo -e "$(tput setaf 1)soundboard just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
#        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
#        gnome-terminal --hide-menubar --profile=SARA



        echo 'Starting vizbox'
        VIZ=$(rospack find vizbox)
        SARACMD="cd $VIZ ; ./server.py"
        SARACMD+='; echo -e "$(tput setaf 1)vizbox just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA

        echo 'Launching ui helper'
        SARACMD='rosrun sara_ui sara_ui_helper'
        SARACMD+='; echo -e "$(tput setaf 1)UI helper just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA



        echo 'Launching Wonderland'
        SARACMD='cd ~/sara_ws/src/wonderland/ ; python manage.py runserver 0.0.0.0:8000'
        SARACMD+='; echo -e "$(tput setaf 1)wonderland just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA



        echo 'Launching flexbe core'
        SARACMD='roslaunch flexbe_onboard behavior_onboard.launch'
        SARACMD+='; echo -e "$(tput setaf 1)flexbe just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA

        echo 'Launching direction to point service'
        SARACMD='rosrun wm_direction_to_point direction_to_point_server.py'
        SARACMD+='; echo -e "$(tput setaf 1)direction to point just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
        gnome-terminal --hide-menubar --profile=SARA

        sleep 2


        if ${SPEECH}
        then
            echo 'Launching google speech to text'
            SARACMD='roslaunch lab_ros_speech_to_text google_tts.launch'
            SARACMD+='; echo -e "$(tput setaf 1)lab_ros_stt just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching speech splitter'
            SARACMD='roslaunch wm_speech_splitter sara_speech.launch'
            SARACMD+='; echo -e "$(tput setaf 1)Speech splitter just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

            echo 'Launching lu4r'
            SARACMD='cd ~/lu4r-0.2.1/lu4r-0.2.1/ ; java -Xmx1G -jar lu4r-server-0.2.1.jar simple amr en 9001'
            SARACMD+='; echo -e "$(tput setaf 1)lu4r just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${VISION}
        then
#            echo 'Launching darknet'
#            SARACMD='roslaunch darknet_ros darknet_ros.launch'
#            SARACMD+='; echo -e "$(tput setaf 1)darknet just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
#            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
#            gnome-terminal --hide-menubar --profile=SARA

            echo 'Launching frame to box'
            SARACMD='roslaunch wm_frame_to_box wm_frame_to_box.launch'
            SARACMD+='; echo -e "$(tput setaf 1)frame_to_box just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

            echo 'Launching color detector'
            SARACMD='roslaunch wm_color_detector wm_color_detector.launch'
            SARACMD+='; echo -e "$(tput setaf 1)color_detector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching face detector'
            SARACMD='roslaunch ros_face_recognition webcam.launch'
            SARACMD+='; echo -e "$(tput setaf 1)face_detector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching data_collector'
            SARACMD='roslaunch wm_data_collector data_collector.launch'
            SARACMD+='; echo -e "$(tput setaf 1)wm_data_collector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA
        fi

        if ${NAV}
        then
            echo 'Launching navigation'
            SARACMD='roslaunch sara_navigation move_base_amcl.launch'
            SARACMD+='; echo -e "$(tput setaf 1)move_base just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi


        if ${STATEMACHINE}
        then
            echo 'Launching flexbe widget'
            SARACMD='roslaunch flexbe_widget behavior_ocs.launch'
            SARACMD+='; echo -e "$(tput setaf 1)flexbe widget just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${RVIZ}
        then
            echo 'Launching rviz'
            SARACMD='rviz'
            SARACMD+='; echo -e "$(tput setaf 1)rviz just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${GENIALE}
        then
            echo 'Launching geniale nodes'
            SARACMD='rosrun robotiq_c_model_control CModelTcpNode.py 192.168.1.11'
            SARACMD+='; echo -e "$(tput setaf 1)geniale node just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${TELEOP}
        then
            echo 'Launching teleop'
            SARACMD='roslaunch sara_teleop sara_teleop.launch'
            SARACMD+='; echo -e "$(tput setaf 1)teleop node just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20'
            gnome-terminal --hide-menubar --profile=SARA

        fi


        echo "fully running"
        echo "Open this link to open vizbox:"
        echo "http://localhost:8888/"
        echo "Or open this link to open wonderland:"
        echo "http://wonderland:8000/admin/"

        while [ -r /dev/dynamixel ] && [ -r /dev/robotiq ] && [ -r /dev/drive1 ] && [ -r /dev/kinova ]
        do
            sleep 1
        done
        echo '$(tput setaf 1)Sara is dead. For now...$(tput setaf 7)'


        cleanup
    done

fi

