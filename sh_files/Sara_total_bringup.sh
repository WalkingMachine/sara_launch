#!/bin/bash


VISION=false
SPEECH=false
HELP=false
STATEMACHINE=false
TELEOP=false
NAV=false
GENIALE=false
RVIZ=false

while getopts "asvhtfngzl:" opt; do

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
        echo ' -h  show this help message'
        echo ' -f  activate flexbe state machine engine'
        echo ' -n  activate autonaumous navigation'
        echo ' -s  activate speech to text'
        echo ' -t  activate teleoperation'
        echo ' -g  geniale node'
        echo ' -v  activate vision stack'
        echo ' -z  start rviz'
        HELP=true  ;;
  esac
done
shift $(( OPTIND - 1 ))



function cleanup {
    echo 'killing all processes'
    for f in $(cat tempPID)
    do
        kill -s 1 $f
    done
    echo > tempPID
}
trap cleanup EXIT











if ! $HELP
then
    while true
    do



        echo 'waiting for power'
        while [ ! -r /dev/dynamixel ] || [ ! -r /dev/robotiq ] || [ ! -r /dev/drive1 ] || [ ! -r /dev/kinova ]
        do
            sleep 1
        done
        echo > tempPID




        echo 'Starting roscore'
        echo 'roscore' > tempCMD
        echo '; echo -e "$(tput setaf 1)roscore just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5


#        echo 'Starting soundboard'
#        echo "" > tempCMD
#        echo '; echo -e "$(tput setaf 1)vizbox just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
#        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
#        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5



        echo 'Starting vizbox'
        VIZ=$(rospack find vizbox)
        echo "cd $VIZ ; ./server.py" > tempCMD
        echo '; echo -e "$(tput setaf 1)vizbox just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        echo 'Launching ui helper'
        echo 'rosrun sara_ui sara_ui_helper' > tempCMD
        echo '; echo -e "$(tput setaf 1)UI helper just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5


        echo 'Setting voice to $LANGUE'
        rosparam set /langue $LANGUE

        echo 'Bringup the hardware'
        echo 'roslaunch sara_launch sara_bringup.launch' > tempCMD
        echo '; echo -e "$(tput setaf 1)sara_bringup just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        echo 'Launching Wonderland'
        echo 'cd ~/sara_ws/wonderland/ ; python manage.py runserver' > tempCMD
        echo '; echo -e "$(tput setaf 1)wonderland just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5



        echo 'Launching flexbe core'
        echo 'roslaunch flexbe_onboard behavior_onboard.launch' > tempCMD
        echo '; echo -e "$(tput setaf 1)flexbe just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
        echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
        sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5


        sleep 2


        if ${SPEECH}
        then
            echo 'Launching google speech to text'
            echo 'roslaunch lab_ros_speech_to_text google_tts.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)lab_ros_stt just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD

            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

            echo 'Launching speech splitter'
            echo 'roslaunch wm_speech_splitter sara_speech.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)Speech splitter just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD

            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

            echo 'Launching lu4r'
            echo 'cd ~/lu4r-0.2.1/lu4r-0.2.1/ ; java -Xmx1G -jar lu4r-server-0.2.1.jar simple amr en 9001' > tempCMD
            echo '; echo -e "$(tput setaf 1)lu4r just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD

            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi

        if ${VISION}
        then
            echo 'Launching darknet'
            echo 'roslaunch darknet_ros darknet_ros.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)darknet just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

            echo 'Launching frame to box'
            echo 'roslaunch wm_frame_to_box wm_frame_to_box.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)frame_to_box just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

            echo 'Launching color detector'
            echo 'roslaunch wm_color_detector wm_color_detector.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)color_detector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

            echo 'Launching data_collector'
            echo 'roslaunch wm_data_collector data_collector.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)wm_data_collector just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi

        if ${NAV}
        then
            echo 'Launching navigation'
            echo 'roslaunch sara_navigation move_base_amcl.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)move_base just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi


        if ${STATEMACHINE}
        then
            echo 'Launching flexbe widget'
            echo 'roslaunch flexbe_widget behavior_ocs.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)flexbe widget just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi

        if ${RVIZ}
        then
            echo 'Launching rviz'
            echo 'rviz' > tempCMD
            echo '; echo -e "$(tput setaf 1)rviz just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi

        if ${GENIALE}
        then
            echo 'Launching geniale nodes'
            echo 'rosrun robotiq_c_model_control CModelTcpNode.py 192.168.1.11' > tempCMD
            echo '; echo -e "$(tput setaf 1)geniale node just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi


        sleep 10
        if ${TELEOP}
        then
            echo 'Launching teleop'
            echo 'roslaunch sara_teleop sara_teleop.launch' > tempCMD
            echo '; echo -e "$(tput setaf 1)teleop node just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)' >> tempCMD
            echo '; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"; sleep 20' >> tempCMD
            sleep 0.5 ; gnome-terminal --hide-menubar --profile=SARA ; sleep 0.5

        fi


        echo "fully running"


        while [ -r /dev/dynamixel ] && [ -r /dev/robotiq ] && [ -r /dev/drive1 ] && [ -r /dev/kinova ]
        do
            sleep 1
        done
        echo '$(tput setaf 1)Sara is dead. For now...$(tput setaf 7)'





        cleanup
    done

fi

