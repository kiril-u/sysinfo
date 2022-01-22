#!/bin/bash
# SOFTWARE:
function os { cat /etc/*-release | grep "PRETTY_NAME" | cut -d "\"" -f2; } # Operation System
function userhost { printf "$(tput setaf 2)$(logname)$(tput sgr0)$(tput setaf 5)@$(tput sgr0)$(tput setaf 2)$(tput bold)$(hostname)$(tput sgr0)"; } #user[at]hostname
function kernel { awk '/Linux/ {print $3;}' /proc/version; } # Kernel version
function your_shell {
local users_shell=$(echo $SHELL | cut -d "/" -f3)
case $users_shell in
	bash) echo "$users_shell $BASH_VERSION" ;;
	tcsh) echo "$users_shell $version" ;;
	zsh) echo "$users_shell $ZSH_VERSION" ;;
	ksh) echo "$users_shell $KSH_VERSION" ;;
	fish) echo "$users_shell $version" ;;
	*) echo "Your shell could not be determined, try running -shell tryharder" ;; # this will be changed.
esac
} # outouts users shell and shell version
function terminal { printf $TERM | cut -d "-" -f2; } # Displays the name of your terminal emulator
function packages { dpkg --list | grep "i" | wc --lines || yum list installed | grep wc --lines || pacman -Q | wc -l; } # Number of packages installed from the package manager.
function flatpaks { flatpak list | wc --lines; }
function snaps { local var=$(snap list | wc -l); expr $var - 1; }
function up_time { uptime -p | awk '{print $2 " " $3 " " $4 " " $5;}'; } # Displays up time. This one may be buggy because I haven't tested it on a machine that was on for more than a day.
# HARDWARE:
function cpu { local cpu_name=$(cat /proc/cpuinfo | grep "model name" -m 1 | cut -d ":" -f2); echo -ne "$cpu_name "; } # CPU model 
function cpu_cores { local num_cores=$(cat /proc/cpuinfo | cat /proc/cpuinfo | grep "cpu cores" -m 1  | cut -d ":" -f2); echo -ne "$num_cores"; } # Number of cores
function cpu_temp { sensors | awk '/^CPU:/ {print $2}'; } # CPU temperature
function cpu_usage { printf "$(ps -A -o pcpu | tail -n+2 | paste -sd+ | bc)%%"; } # shows CPU usage by percentage
function battery { upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"; } # Shows battery's state and how charged it is
function battery_alt { if test -f "/sys/class/power_supply/BAT0"; then
        printf "BAT: $(cat /sys/class/power_supply/BAT0/capacity)%%"
else
        printf "AC"
fi; }
function gpu {
GPU=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2); echo $GPU $RAM; } # GPU info
function display_resolution { xdpyinfo | awk '/dimensions/ {print $2}'; } # Current display resolution
function ram { free --mega | awk '/^Mem:/ {print $3 "MB / " $2 " MB"}'; } # Shows memory used/total memory
function ram_percentage { printf " ($(awk '/^Mem/ {printf("%u%%", 100*$3/$2)}' <(free -m))%)"; }
function storage { df -ht ext4 --total | awk '/^total/ {print $3 "/" $2}'; } # Shows storage used / total storage
# PROCESSES
function proc_mem { ps axch -o cmd:15,%mem --sort=-%mem | head; } # Shows X most memory intensive processes
function proc_cpu { ps axch -o cmd:15,%cpu --sort=-%cpu | head; } # Shows X most cpu intensive processes
# PRINT Temporary (Testing previous functions)
printf "\n" && echo "------------------------" && userhost && printf "\n" && echo "------------------------"
printf "$(tput setaf 2)OS: $(tput sgr0)" && os
printf "$(tput setaf 2)Kernel: $(tput sgr0)" && kernel
printf "$(tput setaf 2)Uptime: $(tput sgr0)" && up_time
printf "$(tput setaf 2)Packages: $(tput sgr0)" && packages && flatpaks && snaps
printf "$(tput setaf 2)Shell: $(tput sgr0)" && your_shell
printf "$(tput setaf 2)Terminal: $(tput sgr0)" && terminal
printf "$(tput setaf 2)CPU: $(tput sgr0)" && cpu && printf "," && cpu_cores && printf " cores.\n"
printf "$(tput setaf 2)CPU usage: $(tput sgr0)" && cpu_usage && printf " | $(tput setaf 2)CPU Temp: $(tput sgr0)" && cpu_temp
printf "$(tput setaf 2)Resolution: $(tput sgr0)" && display_resolution
printf "$(tput setaf 2)GPU: $(tput sgr0)" && gpu
printf "$(tput setaf 2)Memory: $(tput sgr0)" && ram
printf "$(tput setaf 2)Storage: $(tput sgr0)" && storage
printf "$(tput setaf 2)Battery: $(tput sgr0) " && battery_alt && printf " \n" && battery
echo "------------------------"
echo "$(tput setaf 2)Top 10 processes sorted by memory usage:$(tput sgr0)" && proc_mem
echo "------------------------"
echo "$(tput setaf 2)Top 10 processes sorted by CPU usage:$(tput sgr0)" && proc_cpu
