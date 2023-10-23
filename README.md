# fdmonitor

---

## Usage:
`./fdmonitor.sh <pattern>`

## Description

This script will find the currently running process with a name matching `<pattern>`

Then it will display the PIDs, states and opened file descriptors for this process and all it's children.

---

### Notes

Zombie 🧟 processes are BAD and their file descriptors cannot be obtained

Written with the idea to help developpment of 42 school project pipex and, mostly, minishell.
Tested on Ubuntu 22.04.2 LTS

---

### Visuals

![Zombies in my minishell, this is bad](/zombies.png)

![No zombies, perfect piping, this is beautiful](/nozombies.png)
