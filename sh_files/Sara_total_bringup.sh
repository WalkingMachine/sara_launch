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
    o) FORCEOFFLINE=true ;;
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
        echo ' -m  activate slam gmaping mode. For mapping.'
        echo ' -o  force the offline mode.'
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
    SARACMDSTRING='( while true ; do setTitle '"$Name"' ; sleep 2 ; done ) & '
    SARACMDSTRING+="history -s SARACMD ;"
    SARACMDSTRING+=$Command
    SARACMDSTRING+='; echo -e "$(tput setaf 1)'"$Name"' just died$(tput setaf 7)$(tput setab 0)$(tput setaf 7)$(tput setab 0)" >> $(tty)'
    SARACMDSTRING+='; echo -e "$(tput setaf 1)$(tput setab 7)Im dead"'
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
    if ! [ $(ssh -t -t nvidia@sara-jetson1 "echo ok" ) ]
    then
        echo "$(tput setaf 1)No connection to Jetson$(tput setaf 7)"
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
export SARACMDSTRING
export PIDFile



####################################################################
#                         MAIN PROGRAM                             #
####################################################################

if ! $HELP
then


    ####################################################
    # Kill all remaining processes if needed
    cleanup_all

    ####################################################
    # Launch all persistent processes

    start_terminal_node "roscore" "roscore" ""$PIDFILENAMEPERSISTENT""

    sleep 3

    if ${FORCEOFFLINE}
        then
        rosparam set /force_offline true
    fi

    echo "Load categoryToNames.yaml"
    rosparam load ~/sara_ws/src/sara_launch/sh_files/ressources/categoryToNames.yaml CategoryToNames
    echo "Setting voice to $LANGUE"
    rosparam set /langue $LANGUE

    start_terminal_node "SOUNDBOARD" 'roslaunch wm_sound_library wm_soundboard.launch'  ""$PIDFILENAMEPERSISTENT""
    start_terminal_node "MARY_TTS" "cd ~/sara_ws/src/marytts ; ./gradlew run"  ""$PIDFILENAMEPERSISTENT""
    start_terminal_node "WONDERLAND" 'cd ~/sara_ws/src/wonderland/ ; python manage.py runserver 0.0.0.0:8000'  "$PIDFILENAMEPERSISTENT"

    if ${SPEECH}
    then
        if ${FORCEOFFLINE}
        then
            start_terminal_node "SNIPS_STT" 'roslaunch wm_snips_asr wm_snips_asr.launch'  "$PIDFILENAMEPERSISTENT"
        else
            start_terminal_node "GOOGLE_STT" 'roslaunch success_google_stt google_stt.launch method:=mic'  "$PIDFILENAMEPERSISTENT"
            start_terminal_node "SPEECH_SPLITTER" 'roslaunch wm_speech_splitter sara_speech.launch'  "$PIDFILENAMEPERSISTENT"
        fi
    fi

    start_terminal_node "WM_TTS" 'roslaunch wm_tts wm_tts.launch'  "$PIDFILENAMEPERSISTENT"

    start_terminal_node "SARA_SAID_AND_EARD" 'rostopic echo /sara_command & rostopic echo /sara_said'  "$PIDFILENAMEPERSISTENT"


    sleep 2
    rostopic pub /say wm_tts/say "sentence: 'My brain is ready.'
emotion: 0" --once

    # Loop forever
    while true
    do

        if ! check_usb_devices
        then
rostopic pub /say wm_tts/say "sentence: 'Wait! I dont feel my body. What appened to me?'
emotion: 0" --once

            echo 'waiting for power'
            while ! check_usb_devices
            do
            tree /dev/SARA
            echo "====================="
                sleep 1
            done
rostopic pub /say wm_tts/say "sentence: 'Thanks! I feel better now!'
emotion: 0" --once

        fi



rostopic pub /say wm_tts/say "sentence: 'Initiating hardware connection.'
emotion: 0" --once

        clear
        echo "======================="
        echo "=== IT'S HAPPENING! ==="
        echo "======================="
        echo



        ####################################################
        # Launch all hardware dependent processes


#        rosparam set use_sim_time true
#        date --set="$ssh nvidia@sara-jetson1"


        start_terminal_node "SARA_HARDWARE" 'roslaunch sara_launch sara_bringup.launch'  "$PIDFILENAMEESTOP"


        VIZ=$(rospack find vizbox)
        start_terminal_node "VIZBOX" "cd $VIZ ; ./server.py"  "$PIDFILENAMEESTOP"

        sleep 2



rosservice call /wm_play_sound "play:
  data: 'sara-start.wav'"


    sleep 2


        echo "fully running"
        echo "Open this link to open vizbox:"
        echo "http://localhost:8888/"
        echo "Or open this link to open wonderland:"
        echo "http://wonderland:8000/admin/"

        sleep 2



rostopic pub /say wm_tts/say "sentence: 'Sara the Walking Machine. Ready to roll out!'
emotion: 0" --once


        while check_usb_devices
        do
            sleep 1
        done


rostopic pub /say wm_tts/say "sentence: 'Oh my! I dont feel good at all!'
emotion: 0" --once
        ####################################################
        # Kill all hardware dependent processes

        echo '$(tput setaf 1)Sara is dead. For now...$(tput setaf 7)'


        cleanup "$PIDFILENAMEESTOP"
    done
fi
