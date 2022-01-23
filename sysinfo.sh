#!/bin/bash
# sysinfo - A minimalist command-line system information tool written in bash.
# Copyright (c) 2022 Kiril Urivsky
# https://github.com/kiril-u/sysinfo
# sysinfo is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# sysinfo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with sysinfo. If not, see <https://www.gnu.org/licenses/>.
version=0.01
# ------------------- SOFTWARE: -------------------
function os { cat /etc/*-release | grep "PRETTY_NAME" | cut -d "\"" -f2; } # Operation System
function userhost { printf "$(tput setaf 2)$(logname)$(tput sgr0)$(tput setaf 5)@$(tput sgr0)$(tput setaf 2)$(tput bold)$(hostname)$(tput sgr0)"; } #user[at]hostname
function kernel { awk '/Linux/ {print $1 " " $3;}' /proc/version; } # Kernel version
function your_shell {
	local users_shell=$(echo $SHELL | cut -d "/" -f3)
	case $users_shell in
		bash) echo "$users_shell $BASH_VERSION" ;;
		tcsh) echo "$users_shell $version" ;;
		zsh) echo "$users_shell $ZSH_VERSION" ;;
		ksh) echo "$users_shell $KSH_VERSION" ;;
		fish) echo "$users_shell $version" ;;
		*) echo "Your shell could not be determined, try running -shell tryharder" ;; # this will be changed.
	esac; } # outouts users shell and shell version
function terminal { printf $TERM | cut -d "-" -f2; } # Displays the name of your terminal emulator
function packages { 
local num_pkg=$(dpkg --list | grep "i" | wc --lines || yum list installed | grep wc --lines || pacman -Q | wc -l) 
local num_flatpaks=$(flatpak list | wc --lines)
local var=$(snap list | wc -l)
local num_snaps=$(expr $var - 1)
local pkg_man=$(package_manager)
echo "$num_pkg ($pkg_man), $num_flatpaks (flatpaks), $num_snaps (snaps)"
} # Number of packages installed from the package manager.
function package_manager {
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        printf "${osInfo[$f]}"
    fi
done
}
function up_time { uptime -p | awk '{print $2 " " $3 " " $4 " " $5 " " $6 " " $7;}'; } # Displays up time. This one may be buggy because I haven't tested it on a machine that was on for more than a day.
function de { echo -n "${XDG_CURRENT_DESKTOP} ${XDG_SESSION_DESKTOP^}"; }
function editor { printf "${VISUAL:-$EDITOR}"; }
# ------------------- HARDWARE: -------------------
function cpu { local cpu_name=$(cat /proc/cpuinfo | grep "model name" -m 1 | cut -d ":" -f2); echo -ne "$cpu_name "; } # CPU model 
function cpu_cores { local num_cores=$(cat /proc/cpuinfo | cat /proc/cpuinfo | grep "cpu cores" -m 1  | cut -d ":" -f2); echo -ne "$num_cores"; } # Number of cores
function cpu_temp { sensors | awk '/^CPU:/ {print $2}'; } # CPU temperature
# function cpu_usage { printf "$(ps -A -o pcpu | tail -n+2 | paste -sd+ | bc)%%"; } # shows CPU usage by percentage
function battery { upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state|to\ full|percentage"; } # Shows battery's state and how charged it is
function battery_alt { if test -f "/sys/class/power_supply/BAT0"; then
        printf "BAT: $(cat /sys/class/power_supply/BAT0/capacity)%%"
else
        printf "AC"
fi; }
function graphics {
echo -n $(glxinfo -B | grep "OpenGL renderer string" | cut -d ":" -f2); }
# local GPU="$(lspci | grep VGA | cut -d ":" -f3) $(lspci| grep "Display controller" | cut -d ":" -f5)"; }
# function gpu {
# GPU=$(lspci | grep VGA | cut -d ":" -f3);RAM=$(cardid=$(lspci | grep VGA |cut -d " " -f1);lspci -v -s $cardid | grep " prefetchable"| cut -d "=" -f2); echo $GPU $RAM; } # GPU info
function display_resolution { xdpyinfo | awk '/dimensions/ {print $2}'; } # Current display resolution
function ram { 
free --mega | awk '/^Mem:/ {print $3 "MB / " $2 " MB"}'; } # Shows memory used/total memory
function ram_percentage { echo -n "($(awk '/^Mem/ {printf("%u%%", 100*$3/$2)}' <(free -m))%)"; }
function storage { df -ht ext4 --total | awk '/^total/ {print $3 "/" $2}'; } # Shows storage used / total storage
# PROCESSES
function proc_mem { ps axch -o cmd:15,%mem --sort=-%mem | head; } # Shows X most memory intensive processes
function proc_cpu { ps axch -o cmd:15,%cpu --sort=-%cpu | head; } # Shows X most cpu intensive processes
# PRINT Temporary (Testing previous functions)
printf "\n" && echo "------------------------" && userhost && printf "\n" && echo "------------------------"
printf "$(tput setaf 2)OS: $(tput sgr0)" && os
printf "$(tput setaf 2)Kernel: $(tput sgr0)" && kernel
printf "$(tput setaf 2)Uptime: $(tput sgr0)" && up_time
printf "$(tput setaf 2)Packages: $(tput sgr0)" && packages
printf "$(tput setaf 2)Shell: $(tput sgr0)" && your_shell
printf "$(tput setaf 2)DE: $(tput sgr0)" && de && printf "\n"
printf "$(tput setaf 2)Terminal: $(tput sgr0)" && terminal
printf "$(tput setaf 2)CPU: $(tput sgr0)" && cpu && printf "," && cpu_cores && printf " cores\n"
printf "$(tput setaf 2)CPU Temp: $(tput sgr0)" && cpu_temp
printf "$(tput setaf 2)Resolution: $(tput sgr0)" && display_resolution
printf "$(tput setaf 2)GPU: $(tput sgr0)" && graphics && printf "\n"
printf "$(tput setaf 2)Memory: $(tput sgr0)" && ram
printf "$(tput setaf 2)Storage: $(tput sgr0)" && storage
printf "$(tput setaf 2)Battery: $(tput sgr0) " && battery_alt && printf " \n" && battery
echo "------------------------"
echo "$(tput setaf 2)Top 10 processes sorted by memory usage:$(tput sgr0)" && proc_mem
echo "------------------------"
echo "$(tput setaf 2)Top 10 processes sorted by CPU usage:$(tput sgr0)" && proc_cpu
