#!/bin/bash


function get_fds() {
	title="$1 \e[1m$(ps -q $1 -o args=)"
	echo -e -n "\e[0;44m$title"
	cols=$(tput cols)
	for ((i=${#title}; i<cols; i++));do printf " "; done; echo -e "\e[0m"

	pstate_char=";"
	process_status=""
	pstate=$(grep "State" /proc/"$1"/status)
	if [[ $? -eq 0 ]]
	then
		pstate_char="$(echo "$pstate" | awk -e '{print $2}')"
	else
		pstate_char=";"
	fi

	case $pstate_char in
		"R")
			process_status="Runnning 🏃"
		;;
		"S")
			process_status="Sleeping (interruptible) 😴"
		;;
		"D")
			process_status="Sleeping (uninterruptible wait) 😴"
		;;
		"Z")
			process_status="\e[31mZombie\e[0m 🧟"
		;;
		"T")
			process_status="Traced or Stopped 🛑"
		;;
		";")
			process_status="Unknown ❓"
		;;
		*)
			process_status="$(echo "$pstate" | awk -e '{print $2" "$3}')"
		;;
	esac
	echo -e "\e[34m├─\e[0m Process state: $process_status"
	echo -e "\e[34m└─\e[0m Currently opened descriptors:"
	fds=$(ls -o /proc/"$1"/fd 2> /dev/null)
	if [[ $? -ne 0 ]]
	then
		echo -e "\tCould not get fds for this process"
	else
		echo "$fds" | tail --lines=+2 | awk -e '{print "\t"$8" "$9" "$10}'
	fi
}

function get_children() {
	pid_list=$(ps eo pid,ppid,comm | awk -v tpid="$1" -e '{if($2==tpid){print $1}}')
	if [[ "$pid_list" == "" ]]
	then
		echo "No child process found."
	else
		j=0
		for i in $pid_list
		do
			get_fds $i
			echo ""
			j=$j+7
		done
	fi
}

echo ""
if [[ "$1" == "" ]]
then
	echo -e "\e[1;32m▄▀▀   ▄                        ▄"
	echo "█▀▀ ▄▄█    ▄ ▄ ▄   ▄▄  ▄ ▄  ▄ ▄█▄  ▄▄  ▄ ▄▄"
	echo "█  █  █    █▀ █ █ █  █ █▀ █ ▄  █  █  █ █▀"
	echo -e "▀   ▀▀▀    ▀  ▀ ▀  ▀▀  ▀  ▀ ▀   ▀  ▀▀  ▀\e[0m"
	echo -e "\e[4mUsage:\e[0m"
	echo -e "\t\e[1;37m$0 <pattern>\e[0m\n"
	echo -e "This script will find the \e[4mcurrently running process\e[0m with a name matching <pattern>\n"
	echo "Then it will display the PIDs, states and opened file descriptors"
	echo -e "for \e[4mthis process and all it's children\e[0m."
	echo -e "\n\e[31mZombie\e[0m 🧟 processes are \e[1mBAD\e[0m and there file descriptors cannot be obtained"
else
	pslist=$(pgrep -l $1)
	
	if [[ "$pslist" == "" ]]
	then
		echo "No running process matching '$1'."
	elif [[ $(echo "$pslist" | wc -l) -ne 1 ]]
	then
		echo "Multiple running process matching '$1' seems to be running:"
		echo -e " PID    NAME"
		echo "$pslist"
	else
		echo "Running process found: '$(echo $pslist | awk -e '{print $2}')'"
		target_pid=$(echo $pslist | awk -e '{print $1}')
		get_fds "$target_pid"
		echo ""
		get_children "$target_pid"
	fi
fi

