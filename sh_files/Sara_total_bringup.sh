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
        SPEECH=true
        VISION=true
        TELEOP=true
        NAV=true
        RVIZ=true
        JET=true
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
        SARACMD='( while true ; do setTitle ROSCORE ; sleep 2 ; done )'
        SARACMD+='& roscore'
        SARACMD+='; echo -e "$(tput setaf 1)roscore just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA
        sleep 2


        echo "Setting voice to $LANGUE"
        rosparam set /langue $LANGUE

#        rosparam set use_sim_time true
#        date --set="$ssh nvidia@sara-jetson1"

        echo 'Bringup the hardware'
        SARACMD='( while true ; do setTitle SARA_BRINGUP ; sleep 2 ; done )'
        SARACMD+='& roslaunch sara_launch sara_bringup.launch'
        SARACMD+='; echo -e "$(tput setaf 1)sara_bringup just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA

        sleep 1


        if ${JET}
        then

            echo 'Starting jetson'
            SARACMD='( while true ; do setTitle JETSON ; sleep 2 ; done )'
            SARACMD+='& while [ ! $(ssh -t -t nvidia@sara-jetson1 "echo ok" ) ] ; do echo $(tput setaf 3)Still waiting for jetson$(tput setaf 7) ; sleep 1; done'
            SARACMD+="; ssh -t -t nvidia@sara-jetson1 'sudo service ntp stop'"
            SARACMD+="; sleep 1"
            SARACMD+="; ssh -t -t nvidia@sara-jetson1 'sudo ntpd -gq'"
            SARACMD+="; ssh -t -t nvidia@sara-jetson1 'cd /home/nvidia ; roslaunch sara_launch jetson.launch'"
            SARACMD+='; echo -e "$(tput setaf 1)jetson just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA
        fi


#        echo 'Starting soundboard'
#        echo ""
#        SARACMD+='; echo -e "$(tput setaf 1)soundboard just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
#        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
#        gnome-terminal --hide-menubar --profile=SARA



        echo 'Starting vizbox'
        SARACMD='( while true ; do setTitle VIZBOX ; sleep 2 ; done )'
        VIZ=$(rospack find vizbox)
        SARACMD+="& cd $VIZ ; ./server.py"
        SARACMD+='; echo -e "$(tput setaf 1)vizbox just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA

        echo 'Launching ui helper'
        SARACMD='( while true ; do setTitle UI_HELPER ; sleep 2 ; done )'
        SARACMD+='& rosrun sara_ui sara_ui_helper'
        SARACMD+='; echo -e "$(tput setaf 1)UI helper just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA



        echo 'Launching Wonderland'
        SARACMD='( while true ; do setTitle WONDERLAND ; sleep 2 ; done )'
        SARACMD+='& cd ~/sara_ws/src/wonderland/ ; python manage.py runserver 0.0.0.0:8000'
        SARACMD+='; echo -e "$(tput setaf 1)wonderland just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA


        echo 'Launching NLU'
        SARACMD='( while true ; do setTitle RAZA_NLU ; sleep 2 ; done )'
        SARACMD+='& roslaunch wm_nlu wm_nlu.launch'
        SARACMD+='; echo -e "$(tput setaf 1)wm_nlu just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA


        echo 'Launching flexbe core'
        SARACMD='( while true ; do setTitle FLEXBE_ENGINE ; sleep 2 ; done )'
        SARACMD+='& roslaunch flexbe_onboard behavior_onboard.launch'
        SARACMD+='; echo -e "$(tput setaf 1)flexbe just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA

        echo 'Launching direction to point service'
        SARACMD='( while true ; do setTitle DIRECTION_TO_POINT ; sleep 2 ; done )'
        SARACMD+='& rosrun wm_direction_to_point direction_to_point_server.py'
        SARACMD+='; echo -e "$(tput setaf 1)direction to point just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
        SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
        gnome-terminal --hide-menubar --profile=SARA

        sleep 2


        if ${SPEECH}
        then
            echo 'Launching google speech to text'
            SARACMD='( while true ; do setTitle LAB_ROS_STT ; sleep 2 ; done )'
            SARACMD+='& roslaunch lab_ros_speech_to_text google_tts.launch'
            SARACMD+='; echo -e "$(tput setaf 1)lab_ros_stt just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching speech splitter'
            SARACMD='( while true ; do setTitle SPEECH_SPLITTER ; sleep 2 ; done )'
            SARACMD+='& roslaunch wm_speech_splitter sara_speech.launch'
            SARACMD+='; echo -e "$(tput setaf 1)Speech splitter just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${VISION}
        then
#            echo 'Launching darknet'
#            SARACMD='roslaunch darknet_ros darknet_ros.launch'
#            SARACMD+='; echo -e "$(tput setaf 1)darknet just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
#            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
#            gnome-terminal --hide-menubar --profile=SARA

            echo 'Launching frame to box'
            SARACMD='( while true ; do setTitle FRAME_TO_BOX ; sleep 2 ; done )'
            SARACMD+='& roslaunch wm_frame_to_box wm_frame_to_box.launch'
            SARACMD+='; echo -e "$(tput setaf 1)frame_to_box just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA

            echo 'Launching color detector'
            SARACMD='( while true ; do setTitle COLOR_DETECTOR ; sleep 2 ; done )'
            SARACMD+='& roslaunch wm_color_detector wm_color_detector.launch'
            SARACMD+='; echo -e "$(tput setaf 1)color_detector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching face detector'
            SARACMD='( while true ; do setTitle FACE_DETECTOR ; sleep 2 ; done )'
            SARACMD+='& roslaunch ros_face_recognition ros-face-recognition.launch'
            SARACMD+='; echo -e "$(tput setaf 1)face_detector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA


            echo 'Launching data_collector'
            SARACMD='( while true ; do setTitle DATA_COLLECTOR ; sleep 2 ; done )'
            SARACMD+='& roslaunch wm_data_collector data_collector.launch'
            SARACMD+='; echo -e "$(tput setaf 1)wm_data_collector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA
        fi

        if ${NAV}
        then
            echo 'Launching navigation'
            SARACMD='( while true ; do setTitle NAVIGATION ; sleep 2 ; done )'
            SARACMD+='& roslaunch sara_navigation move_base_amcl.launch'
            SARACMD+='; echo -e "$(tput setaf 1)move_base just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA

        fi


        if ${STATEMACHINE}
        then
            echo 'Launching flexbe widget'
            SARACMD='( while true ; do setTitle FLEXBE_WIDGET ; sleep 2 ; done )'
            SARACMD+='& roslaunch flexbe_widget behavior_ocs.launch'
            SARACMD+='; echo -e "$(tput setaf 1)flexbe widget just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${RVIZ}
        then
            echo 'Launching rviz'
            SARACMD='( while true ; do setTitle RVIZ ; sleep 2 ; done )'
            SARACMD+='& rviz'
            SARACMD+='; echo -e "$(tput setaf 1)rviz just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
            gnome-terminal --hide-menubar --profile=SARA

        fi

        if ${TELEOP}
        then
            echo 'Launching teleop'
            SARACMD='( while true ; do setTitle TELEOP ; sleep 2 ; done )'
            SARACMD+='& roslaunch sara_teleop sara_teleop.launch'
            SARACMD+='; echo -e "$(tput setaf 1)teleop node just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
            SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
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

