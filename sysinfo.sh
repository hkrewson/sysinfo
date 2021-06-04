#!/bin/bash
# Gather and present specific system related information pulled from bios
#   using sudo dmidecode
#################################### GLOBAL ###################################
siBNAME=$(basename "$0")
siDATE="29 Aug, 2017"
siSYS=$(uname)
siPSYS=(Linux GNU FreeBSD Darwin NetBSD OpenBSD SCO)
#################################### GLOBAL ###################################

################################## FUNCTIONS ##################################
siVERSIONf ()
	{
	################################### VERSION ###################################
	# major -- 0=testing >0=release
	# minor -- increment with new features
	# stage 0=alpha, 1=beta, 2=rc, 3=public
	# rev -- number of saves
	# build -- (R)ev(S)tage(M)onth(Y)ear
	siVMAJOR="1"
	siVMINOR="03"
	siSTAGE="2"
	siREV="25"
	siBUILD="2b97"
	siVERSTRING=$(printf "%s.%s.%s.%s %s" "$siVMAJOR" "$siVMINOR" "$siSTAGE" \
		"$siREV" "$siBUILD")
	################################### VERSION ###################################
	printf "\n%s %s\n" "${siBNAME}" "${siVERSTRING}"
	printf "Last revision written %s\n" "${siDATE}"
        printf "Copyright (C) 2017 H. R. Krewson\n"
        printf "Licensed under the Apache License, Version 2.0\n"
        printf "http://www.apache.org/licenses/LICENSE-2.0\n"
        printf "\n"
        printf "Written by H. R. Krewson.\n\n"
	exit
	}

siDARWIN ()
	{
		siOS=$(sw_vers -productName)
        siVER=$(sw_vers -productVersion)
        siBLD=$(sw_vers -buildVersion)
        siREL=$(printf "%s %s (%s)" "$siOS" "$siVER" "$siBLD")
        siCUR=$(sw_vers -productVersion | awk -F. '{print $2}' | tr -d '\n')
        case $siCUR in
                 3) siDIST="Mac OS X Panther";;
                 4) siDIST="Mac OS X Tiger";;
                 5) siDIST="Mac OS X Leopard";;
                 6) siDIST="Mac OS X Snow Leopard";;
                 7) siDIST="Mac OS X Lion";;
                 8) siDIST="Mac OS X Mountain Lion";;
                 9) siDIST="Mac OS X Mavericks";;
                10) siDIST="Mac OS X Yosemite";;
                11) siDIST="Mac OS X El Capitan";;
                12) siDIST="macOS Sierra";;
                13) siDIST="macOS High Sierra";;
        esac
        siMAN="Apple Inc."
        siPROD=$(system_profiler SPHardwareDataType | awk -F": " '/Identifier/{printf "%s", $2}')
        siSSN=$(system_profiler SPHardwareDataType | awk -F": " '/Serial/{printf "%s", $2}')
        siBIOS=$(system_profiler SPHardwareDataType | awk -F": " '/Boot/{printf "Boot Rom %s", $2}')
        siBIOSV=$(system_profiler SPHardwareDataType | awk -F": " '/SMC/{printf ", SMC %s", $2}')
        siLOG="N/A"
        siLTP=""
        siLSN="N/A"
        siPROC=$(system_profiler SPHardwareDataType | awk -F": " '/Processor\ Name/{printf "%s", $2}';\
        	system_profiler SPHardwareDataType | awk -F": " '/Processor\ Speed/{printf ", %s", $2}')
        siMMAX="Check specs."
        siMEM=$(system_profiler SPHardwareDataType | awk -F": " '/Memory/{printf "%s", $2}')
	}

siLSBREL ()
	{
	siDMI
	siDIST=$(lsb_release -i | awk -F":\t" '{printf "%s", $2}')
    siREL=$(lsb_release -d | awk -F'[":\t""("]' '{gsub(/ +$/, "", $3); printf "%s", $3}';\
	     lsb_release -c | awk -F":\t" '{printf " (%s)", $2}')
	}

siRASP ()
	{
		siSSN=$(tr -d '\0' </proc/device-tree/serial-number)
		siMAN="Raspberry Pi Foundation"
		siPROD=$(tr -d '\0' </proc/device-tree/model | awk -F'Model' '{printf $1}')
		siPROC=$(tr -d '\0' </proc/device-tree/cpus/cpu@0/compatible | awk -F, '{printf $1" "$2}' | sed -e 's/\b\(.\)/\u\1/g')
		siMMAX=$siMEM
		siLSN=$siSSN
		siLOG=$(tr -d '\0' </proc/device-tree/model | awk -F'Model' '{printf "Model"$2}')
		siBIOS=$(rpi-eeprom-update | grep 'LATEST' | awk -F': ' 'NR==1{printf $2}')
		siBIOSV=$(rpi-eeprom-update | grep 'LATEST' | awk -F': ' 'NR==2{printf $2}')
	}
siDEFAULT ()
	{
	siDMI
	siREL=$(cat /etc/*release | grep "PRETTY" | \
		awk -F= '{gsub(/"/, "", $2); printf "%s", $2}')
	siDIST=$(cat /etc/*release | grep '\<NAME' | \
		awk -F= '{gsub(/"/, "", $2); printf "%s", $2}')
	}

siDMI ()
	{
	# Step 1 gather information desired.
	# System
	siMAN=$(sudo dmidecode -s system-manufacturer)
	siPROD=$(sudo dmidecode -s system-product-name)
	siSSN=$(sudo dmidecode -s system-serial-number)

	# Bios
	# use awk printf to remove undesired whitespace
	siBIOS=$(sudo dmidecode -s bios-vendor)
	siBIOSV=$(sudo dmidecode -s bios-version | awk '{printf "%s", $1}';\
		sudo dmidecode -t bios | grep "Revision" | awk -F": " '{printf " rev-%s", $2}')

	# Logic Board Info
	siLOG=$(sudo dmidecode -s baseboard-product-name)
	siLTP=$(sudo dmidecode -s baseboard-version | cut -d' ' -f1 -)
	siLSN=$(sudo dmidecode -s baseboard-serial-number)

	# Processor
	siPROC=$(sudo dmidecode -s processor-version | awk 'FNR==1 {printf $n}')

	# Memory
	siMMAX=$(sudo dmidecode -t memory | grep "Maximum Capacity" | \
		awk -F': ' '{printf "%.2f GiB (%.f GB)", $2 * .953674, $2}')

	siMEM=$(free -m | awk 'FNR == 2 {printf "%.2f GiB ( %.f GB)", $2/1024, $2/1024}')
	# Alternate form for locating and displaying installed memory
	# siMEM=$(sudo dmidecode -t memory | grep "Size" | \
	# awk 'BEGIN {c=0}; NR==7 {a=$2};NR==8 {b=$2}; {c=a+b} END {print c}')	
	}
################################## FUNCTIONS ##################################


while getopts "v" opt; do
	case $opt in
		v) siVERSIONf;;
	esac
done

################################# DEPENDENCIES ################################
if [[ "$siSYS" = "${siPSYS[3]}" ]]; then
	siDARWIN
elif [[ ! -f $(which lsb_release) ]]; then
	printf "%s requires lsb_release, please install.", "$siBNAME" 
	printf "Attempting to gather information without lsb_release."
	siDEFAULT
else
	siLSBREL
	siRASP
fi
################################# DEPENDENCIES ################################


# OS Release
# gsub(/"/, "", $2) -- remove surround quotation marks
# http://stackoverflow.com/questions/19474860/remove-quotes-in-awk-command
# gsub(/ +$/, "", $3) -- remove trailing spaces
# https://stackoverflow.com/questions/20600982


# Print formatted for the shell.
printf "\n"
printf "%25s %s %s\n" "Manufacturer:" "$siMAN"
printf "%25s %s %s\n" "Computer Model:" "$siPROD"
printf "%25s %s\n" "Serial Number:" "$siSSN"
printf "%25s %s\n" "Distribution:" "$siDIST"
printf "%25s %s\n" "Operating System:" "$siREL"
printf "%25s %s %s\n" "BIOS:" "$siBIOS"
printf "%25s %s %s\n" "BIOS Version:" "$siBIOSV"
printf "%25s %s %s\n" "Logic Board:" "$siLOG $siLTP"
printf "%25s %s\n" "Logic Board Serial:" "$siLSN"
printf "%25s %s\n" "Processor:" "$siPROC"
printf "%25s %s\n" "Memory Installed:" "$siMEM"
printf "%25s %s\n\n" "Maximum Memory:" "$siMMAX" 
