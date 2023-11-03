# fdmonitor

---

## Usage:
`./fdmonitor.sh <pattern> [-m]`

## Description

This script will find the **currently running** processes with a name matching `<pattern>`

Then it will display the PIDs, states and opened file descriptors
for these processes and all their children.

The script accepts to monitor only one parent process by default, use the `-m` option to change that.

---

### Notes

The file descriptors of Zombie 🧟 processes cannot be retreived.

Written with the idea to help developpment of 42 school project pipex and, mostly, minishell.
Tested on Ubuntu 22.04.2 LTS

---

### Visuals

![Zombies in my one of my minishell, this is bad](/screenshot.png)
