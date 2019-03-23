#!/bin/bash


# Define process ID file names
PIDFILENAMEPERSISTENT="tempPIDPersistent"
PIDFILENAMEESTOP="tempPIDEStop"


VISION=false
SPEECH=false
HELP=false
STATEMACHINE=false
TELEOP=false
NAV=false
GENIALE=false
RVIZ=false
JET=true
MAPPING=false
FORCEOFFLINE=false

LANGUE="en-US"

while getopts "asvhtfJngzl:mo" opt; do

  case "$opt" in
    a)
        SPEECH=true
        VISION=true
        TELEOP=true
        NAV=true
        RVIZ=true
        JET=true
        STATEMACHINE=true ;;
    m) MAPPING=true ;;
    n) NAV=true ;;
    s) SPEECH=true ;;
    v) VISION=true ;;
    J) JET=false ;;
    o) FORCEOFFLINE=false ;;
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
        echo ' -o  use the tts in online mode'
        echo ' -s  activate speech to text'
        echo ' -t  activate teleoperation'
        echo ' -v  activate vision stack'
        echo ' -z  start rviz'
        HELP=true  ;;
  esac
done
shift $(( OPTIND - 1 ))

function cleanup_all {
    cleanup "$PIDFILENAMEESTOP"
    cleanup "$PIDFILENAMEPERSISTENT"
}

# Function that can kill all orbital terminals
function cleanup {
    FilePID=$1

    echo "killing all processes on $FilePID"
    for f in $(cat "/tmp/$FilePID")
    do
        kill -s 9 $f
    done
    echo > "/tmp/$FilePID"

}
trap cleanup_all EXIT


function start_terminal_node {
    Name=$1
    Command=$2
    PIDFile=$3

    echo "Starting $Name"
    SARACMD='( while true ; do setTitle '"$Name"' ; sleep 2 ; done ) & '
    SARACMD+=$Command
    SARACMD+='; echo -e "$(tput setaf 1)'"$Name"' just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
    SARACMD+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
    gnome-terminal --hide-menubar --profile=SARA
}


function check_usb_devices {
    result=true
    if ! [ -r /dev/SARA/motors/dynamixel ]
    then
        echo "$(tput setaf 1)No connection to dynamixel$(tput setaf 7)"
        result=false
    fi
    if ! [ -r /dev/SARA/gripper/robotiq ]
    then
        echo "$(tput setaf 1)No connection to robotiq$(tput setaf 7)"
        result=false
    fi
    if ! [ -r /dev/SARA/motors/kinova ] 
    then
        echo "$(tput setaf 1)No connection to kinova$(tput setaf 7)"
        result=false
    fi
    if ! [ -r /dev/SARA/sensors/laser_base ] 
    then
        echo "$(tput setaf 1)No connection to laser_base$(tput setaf 7)"
        result=false
    fi
    if [ -r /dev/SARA/motors/roboteq ]
    then
         if ! [ 4 -eq $(ls -1 /dev/SARA/motors/roboteq | wc -l) ]
        then
            echo "$(tput setaf 1)Missing roboteq drive(s)$(tput setaf 7)"
            result=false
        fi
    else
        echo "$(tput setaf 1)No connection to roboteq drives$(tput setaf 7)"
    fi

    if $result
    then
        true
    else
        false
    fi
}

####################################################################
#                            SETUP                                 #
####################################################################

# Export the variable that will contain the command for each orbital terminals
export SARACMD
export PIDFile



####################################################################
#                         MAIN PROGRAM                             #
####################################################################

if ! $HELP
then

    ####################################################
    # Launch all persistent processes

    echo > /tmp/tempPIDPersistent
    start_terminal_node "roscore" "roscore" ""$PIDFILENAMEPERSISTENT""

    sleep 3

    if ${FORCEOFFLINE}
        then
        rosparam set /force_offline true
    fi

    start_terminal_node "SOUNDBOARD" 'roslaunch wm_sound_library wm_soundboard.launch'  ""$PIDFILENAMEPERSISTENT""

    echo "Load categoryToNames.yaml"
    rosparam load ~/sara_ws/src/sara_launch/sh_files/ressources/categoryToNames.yaml CategoryToNames
    echo "Setting voice to $LANGUE"
    rosparam set /langue $LANGUE

    start_terminal_node "MARY_TTS" "cd ~/sara_ws/src/marytts ; ./gradlew run"  ""$PIDFILENAMEPERSISTENT""



    start_terminal_node "WONDERLAND" 'cd ~/sara_ws/src/wonderland/ ; python manage.py runserver 0.0.0.0:8000'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "WONDERLAND_PUBLISHER" 'rosrun wonderland publish_objects_3D.py'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "SARA_NLU" 'roslaunch wm_nlu wm_nlu.launch'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "FLEXBE_ENGINE" 'roslaunch flexbe_onboard behavior_onboard.launch'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "DTP_SERVICE" 'rosrun wm_direction_to_point direction_to_point_server.py'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "SARA_WEB_INTERFACE" 'roslaunch sara_launch web_interface.launch'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "FRAME_TO_BOX" 'roslaunch wm_frame_to_box wm_frame_to_box.launch'  "$PIDFILENAMEPERSISTENT"


    if ${STATEMACHINE}
    then
        start_terminal_node "FLEXBE_APP" 'roslaunch flexbe_app flexbe_ocs.launch'  "$PIDFILENAMEPERSISTENT"
    fi





    # Loop forever
    while true
    do
        echo 'waiting for power'
        while ! check_usb_devices
        do
        tree /dev/SARA
        echo "====================="
            sleep 1
        done


        clear
        echo "======================="
        echo "=== IT'S HAPPENING! ==="
        echo "======================="
        echo

        echo > /tmp/"$PIDFILENAMEESTOP"





        ####################################################
        # Launch all hardware dependent processes


#        rosparam set use_sim_time true
#        date --set="$ssh nvidia@sara-jetson1"

        start_terminal_node "SARA_HARDWARE" 'roslaunch sara_launch sara_bringup.launch'  "$PIDFILENAMEESTOP"

        sleep 1

        if ${JET}
        then
            COMMAND='while [ ! $(ssh -t -t nvidia@sara-jetson1 "echo ok" ) ] ; do echo $(tput setaf 3)Still waiting for jetson$(tput setaf 7) ; sleep 1; done'
            COMMAND+="; ssh -t -t nvidia@sara-jetson1 'sudo service ntp stop; sudo ntpd -gq'"
            COMMAND+="; ssh -t -t nvidia@sara-jetson1 'cd /home/nvidia ; roslaunch sara_launch jetson.launch'"
            start_terminal_node "JETSON" "$COMMAND"  "$PIDFILENAMEESTOP"
        fi

#        start_terminal_node "SOUNDBOARD" ""  "$PIDFILENAMEESTOP"

        VIZ=$(rospack find vizbox)
        start_terminal_node "VIZBOX" "cd $VIZ ; ./server.py"  "$PIDFILENAMEESTOP"

        start_terminal_node "UI_HELPER" 'rosrun sara_ui sara_ui_helper'  "$PIDFILENAMEESTOP"


        sleep 2



rosservice call /wm_play_sound "play:
  data: 'Engine.wav'"

        if ${SPEECH}
        then
            start_terminal_node "GOOGLE_STT" 'roslaunch lab_ros_speech_to_text google_tts.launch'  "$PIDFILENAMEESTOP"

            start_terminal_node "SPEECH_SPLITTER" 'roslaunch wm_speech_splitter sara_speech.launch'  "$PIDFILENAMEESTOP"
        fi

        if ${NAV}  && ! ${MAPPING}
        then
            start_terminal_node "NAVIGATION" 'roslaunch sara_navigation move_base_amcl.launch'  "$PIDFILENAMEESTOP"
        fi

        if ${MAPPING}
        then
            start_terminal_node "SLAM_NAVIGATION" 'roslaunch sara_launch wm_slam_gmapping.launch'  "$PIDFILENAMEESTOP"
        fi

        if ${RVIZ}
        then
            start_terminal_node "RVIZ" 'rviz'  "$PIDFILENAMEESTOP"
        fi

        if ${TELEOP}
        then
            start_terminal_node "SARA_TELEOP" 'roslaunch sara_teleop sara_teleop.launch'  "$PIDFILENAMEESTOP"
        fi

    sleep 2

        if ${VISION}
        then

            start_terminal_node "COLOR_DETECTOR" 'roslaunch wm_color_detector wm_color_detector.launch'  "$PIDFILENAMEESTOP"

            start_terminal_node "LAPTOP_DARKNET" 'roslaunch darknet_ros darknet_ros.launch darknet_name:=darknet_ros_laptop'  "$PIDFILENAMEESTOP"

            start_terminal_node "FACE_DETECTOR" 'roslaunch ros_face_recognition ros-face-recognition.launch'  "$PIDFILENAMEESTOP"

            start_terminal_node "DATA_COLLECTOR" 'roslaunch wm_data_collector data_collector.launch'  "$PIDFILENAMEESTOP"
        fi

        echo "fully running"
        echo "Open this link to open vizbox:"
        echo "http://localhost:8888/"
        echo "Or open this link to open wonderland:"
        echo "http://wonderland:8000/admin/"

        sleep 2



        start_terminal_node "WM_TTS" 'roslaunch wm_tts wm_tts.launch'  "$PIDFILENAMEESTOP"


rostopic pub /say wm_tts/say "sentence: 'Walking Machine. Operationnal.'
emotion: 0" --once


        while check_usb_devices
        do
            sleep 1
        done



        ####################################################
        # Kill all hardware dependent processes

        echo '$(tput setaf 1)Sara is dead. For now...$(tput setaf 7)'


        cleanup "$PIDFILENAMEESTOP"
    done
fi
