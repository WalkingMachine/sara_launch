#!/bin/bash


VISION=false
SPEECH=false
HELP=false
STATEMACHINE=false
TELE=false
NAV=false
while getopts "asvhtfn" opt; do
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
		echo " -v  activate vision stack"
		HELP=true  ;;
  esac
done
shift $(( OPTIND - 1 ))

if ! $HELP
then

	gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roscore ; echo 'roscore just died' >> /dev/stderr"
	sleep 3

	echo "Bringup the hardware"
	gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch sara_launch sara_bringup.launch; echo 'Bringup just died' >> /dev/stderr"

	echo "Launching Wonderland"
	gnome-terminal --profile=Bringup -x bash -c "cd ~/sara_ws/wonderland/ ; python manage.py runserver; echo 'wonderland just died' >> /dev/stderr"


	if $SPEECH
	then
		echo "Launching google speech to text"
		gnome-terminal --profile=Voice -x bash -c "cd ~ ; source .bashrc ; roslaunch lab_ros_speech_to_text google_tts.launch; echo 'lab_ros_stt just died' >> /dev/stderr"
		echo "Launching speech splitter"
		gnome-terminal --profile=Voice -x bash -c "source .bashrc ; roslaunch wm_speech_splitter sara_speech.launch; echo 'Speech splitter just died' >> /dev/stderr"
		echo "Launching lu4r"
		gnome-terminal --profile=Voice -x bash -c "cd ~/lu4r-0.2.1/lu4r-0.2.1/ ; java -Xmx1G -jar lu4r-server-0.2.1.jar simple amr en 9001; echo 'lu4r just died' >> /dev/stderr"
		# echo "echo sara_command"
		# gnome-terminal --profile=Voice -x bash -c "source .bashrc ; rostopic echo /sara_command"
	fi

	if $VISION
	then
		echo "Launching darknet"
		gnome-terminal --profile=Vision -x bash -c "source .bashrc ; roslaunch darknet_ros darknet_ros.launch; echo 'darknet just died' >> /dev/stderr"
		echo "Launching frame to box"
		gnome-terminal --profile=Vision -x bash -c "source .bashrc ; roslaunch wm_frame_to_box wm_frame_to_box.launch; echo 'frame_to_box just died' >> /dev/stderr"
	fi

	if $NAV 
	then
		echo "Launching navigation"
		gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch sara_navigation move_base_amcl.launch; echo 'move_base just died' >> /dev/stderr"
	fi


	if $STATEMACHINE
	then
		echo "Launching flexbe core"
		gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch flexbe_onboard behavior_onboard.launch; echo 'flexbe onboard just died' >> /dev/stderr"
		echo "Launching flexbe widget"
		gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; roslaunch flexbe_widget behavior_ocs.launch; echo 'flexbe widget just died' >> /dev/stderr"
	fi

	echo "Launching rviz"
	gnome-terminal --profile=Bringup -x bash -c "source .bashrc ; rviz; echo 'rviz just died' >> /dev/stderr"

	if $TELE
	then
		echo "Launching teleop"
		gnome-terminal --profile=Vision -x bash -c "source .bashrc ; roslaunch sara_teleop sara_teleop.launch; echo 'teleop just died' >> /dev/stderr"
	fi

	sleep 10
fi
