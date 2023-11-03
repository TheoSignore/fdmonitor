#!/bin/bash

indentation=""
function indent() {
	indentation=$(python -c "print(' '*($1) + '│')")
}

disp_pids=""
function is_not_displayed() {
	for i in $disp_pids
	do
		if [[ "$i" == "$1" ]]
		then
			return 0
		fi
	done
	return 1
}

colors="\e[0;44m \e[0;45m \e[0;40m \e[0;46m"
function print_title() {
	cnt=0
	for i in $colors
	do
		if [[ $cnt -eq $2 ]]
		then
			toprint="$i$1"
			echo -e -n "$toprint"
			cols=$(tput cols)
			for ((i=${#toprint}; i<cols; i++));do printf " "; done; echo -e "\e[0m"
			return 0
		fi
		cnt=$(expr $cnt '+' 1)
	done
	echo -e "$toprint"
}

function get_pstate() {
	pstate_char=";"
	process_status=""
	pstate=$(grep "State" /proc/"$1"/status 2> /dev/null)
	if [[ $? -eq 0 ]]
	then
		pstate_char="$(echo "$pstate" | awk -e '{print $2}')"
	else
		pstate_char=";"
	fi

	case $pstate_char in
		"R")
			echo "Runnning 🏃"
		;;
		"r")
			echo "Runnning 🏃"
		;;
		"S")
			echo "Sleeping (interruptible) 😴"
		;;
		"s")
			echo "Sleeping (interruptible) 😴"
		;;
		"D")
			echo "Sleeping (uninterruptible wait) 😴"
		;;
		"d")
			echo "Sleeping (uninterruptible wait) 😴"
		;;
		"Z")
			echo "\e[31mZombie\e[0m 🧟"
		;;
		"z")
			echo "\e[31mZombie\e[0m 🧟"
		;;
		"t")
			echo "Traced or Stopped 🛑"
		;;
		"T")
			echo "Traced or Stopped 🛑"
		;;
		"I")
			echo "Idle 🌙"
		;;
		"i")
			echo "Idle 🌙"
		;;
		";")
			echo "Unknown ❓"
		;;
		*)
			echo "$(echo "$pstate" | awk -e '{print $2" "$3}')"
		;;
	esac
}

function get_and_print_fds() {
	fds=$(ls -o /proc/"$1"/fd 2> /dev/null)
	if [[ $? -ne 0 ]]
	then
		echo -e "$indentation\tCould not get fds for this process"
	else
		echo "$fds" | tail --lines=+2 | awk -v idnt="$indentation" -e '{print idnt"\t"$8" "$9" "$10}'
	fi
}

function monitor() {
	idntlevel=$2
	is_not_displayed $1
	if [[ $? -eq 0 ]]
	then
		return 0
	fi
	title=" $1 \e[1m$(ps -q $1 -o args=)"
	if [[ $idntlevel -eq 0 ]]
	then
		echo -n "┌─"
	elif [[ $3 -eq 0 ]]
	then
		echo -e -n "$indentation\b└┬─"
	else
		echo -e -n "$indentation\b├─"
	fi
	print_title "$title" $idntlevel
	indent $idntlevel

	echo -e "$indentation Process state: $(get_pstate $1)"
	echo -e "$indentation Currently opened file descriptors:"
	get_and_print_fds $1
	disp_pids+="$1 "
	echo "$indentation"
	get_children "$1" "$(expr $idntlevel '+' 1)"
}

function get_children() {
	pid_list=$(ps eo pid,ppid,comm | awk -v tpid="$1" -e '{if($2==tpid){print $1}}')
	if [[ "$pid_list" == "" ]]
	then
		echo "$indentation No child process found."
	else
		echo -e "$indentation $(echo "$pid_list" | wc -l) child process found:"
		#echo -n ""
		j=0
		for i in $pid_list
		do
			monitor $i $2 $j ;
			j=$(expr $j '+' 7) ;
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
	echo -e "\t\e[1;37m$0 <pattern> [-m]\e[0m\n"
	echo -e "This script will find the \e[4mcurrently running processes\e[0m with a name matching <pattern>\n"
	echo "Then it will display the PIDs, states and opened file descriptors"
	echo -e "for \e[4mthese processes and all their children\e[0m."
	echo -e "\nThe script accepts to monitor only one parent process by default, use the \e[1m-m\e[0m option to change that."
	echo -e "\nThe file descriptors of \e[31mZombie\e[0m 🧟 processes cannot be obtained"
else
	pslist=$(pgrep -l $1)
	
	if [[ "$pslist" == "" ]]
	then
		echo "No running process matching '$1'."
	else
		echo "$(echo "$pslist" | wc -l) running process matching '$1'"
		if [[ $(echo "$pslist" | wc -l) -ne 1 && "$2" != "-m" ]]
		then
			echo -e " PID    NAME"
			echo "$pslist"
			echo -e "Use \e[1m$0 $1 -m\e[0m to proceed."
		else
			for i in $(echo "$pslist" | awk -e '{print $1}')
			do
				monitor "$i" 0 0
				echo ""
			done
		fi
		
	fi
fi

