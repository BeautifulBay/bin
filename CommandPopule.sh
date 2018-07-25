#!/bin/bash

function _completeFunc()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"

	if [ $# -ge 2 -a ${COMP_CWORD}x = $2x ]
	then
		if [ ${COMP_WORDS[COMP_CWORD-1]} = "getGitLog.py" ]; then
			compopt -o nospace
		fi
		COMPREPLY=($(compgen -W "$1" -- $cur))
		return 0
	elif [ $# -ge 4 -a ${COMP_CWORD}x = $4x ]
	then
		COMPREPLY=($(compgen -W "$3" -- $cur))
		return 0
	fi
}

function _mkDir()
{
	local opts="android kernel packages modem lk"
	_completeFunc "$opts" 2
}

function _getGitLog()
{
	local opts="--author= --after= --before= --since= --branches --date="
	_completeFunc "$opts" 1
}

function _cAndroid()
{
	local opts="android kernel bootable device system vendor frameworks packages hardware out build dts dts64 power lk obj modem qcom32 qcom64 product"
	_completeFunc "$opts" 1
}

function Cd()
{
	local destination=""
	local currentDir=`pwd -P`
	local TOPFILE=build/core/envsetup.mk
: << !
	if [ `basename ${currentDir}` == "modem" ]; then
		if [ -f ${currentDir}/../${TOPFILE} ]; then
			cd ${currentDir}/../
		else
			for var in `ls ../`
			do
				if [ -f ${currentDir}/../$var/${TOPFILE} ]; then
					cd ${currentDir}/../$var
					break
				fi
			done
		fi
	fi
!
	local HERE=`pwd -P`
	currentDir=`pwd -P`
	while [ ! -f $TOPFILE -a $currentDir != "/" ]
	do
		if [ `basename ${currentDir}` == "modem" ]; then
			if [ -f ${currentDir}/../${TOPFILE} ]; then
				cd ${currentDir}/../
			else
				for var in `ls ../`
				do
					if [ -f ${currentDir}/../$var/${TOPFILE} ]; then
						cd ${currentDir}/../$var
						break
					fi
				done
			fi
		else
			cd ../
		fi
		currentDir=`pwd -P`
	done
	cd $HERE
	if [ ! -f $currentDir/$TOPFILE ]; then
		echo "You are not in an android product directory, Please check"
		return
	fi

	case ${1%%/*} in
	"modem")
		if [ -d ${currentDir}/../modem ];then
			destination=${currentDir}/../modem
		elif [ -d ${currentDir}/modem ];then
			destination=${currentDir}/modem
		else
			echo "There is no modem directory"
			return
		fi
		;;
	"dts")
		destination=${currentDir}/kernel/arch/arm/boot/$1
		;;
	"dts64")
		destination=${currentDir}/kernel/arch/arm64/boot/dts
		;;
	"qcom")
		if [ -d ${currentDir}/kernel/arch/arm/boot/dts/qcom ]; then
			destination=${currentDir}/kernel/arch/arm/boot/dts/qcom
		elif [ -d ${currentDir}/kernel/msm-3.18/arch/arm/boot/dts/qcom ]; then
			destination=${currentDir}/kernel/msm-3.18/arch/arm/boot/dts/qcom
		fi
		;;
	"qcom64")
		if [ -d ${currentDir}/kernel/arch/arm64/boot/dts/qcom ]; then
			destination=${currentDir}/kernel/arch/arm64/boot/dts/qcom
		elif [ -d ${currentDir}/kernel/msm-3.18/arch/arm64/boot/dts/qcom ]; then
			destination=${currentDir}/kernel/msm-3.18/arch/arm64/boot/dts/qcom
			if [ -d ${currentDir}/kernel/msm-3.18/arch/arm64/boot/dts/qcom/qs5737 ]; then
				destination=${currentDir}/kernel/msm-3.18/arch/arm64/boot/dts/qcom/qs5737
			fi
		fi
		;;
	"power")
		destination=${currentDir}/kernel/drivers/$1
		;;
	"lk")
		destination=${currentDir}/bootable/bootloader/$1
		;;
	"obj" | "product")
		local var 
		for var in `ls ${currentDir}/out/target/product/`
		do
			if [ $var != "generic" ]; then
				destination=${currentDir}/out/target/product/$var
				break
			fi
		done
		[ -z $destination ] && echo "There is no product directory under out/target/product/" && return 
		[ $1 == "obj" ] && destination=${destination}/$1
		;;
	"android")
		destination=${currentDir}
		;;
	*)
		destination=${currentDir}/$1
		;;
	esac

	cd ${destination}
}

: << !
function _Cd()
{
	local option first last
	local currentDir=`pwd`
	if [[ ! $currentDir =~ "android" && ! $currentDir =~ "modem" && ! $currentDir =~ "alps" ]]
	then
		for var in `ls`
		do
			if [[ $var =~ "android" ]]
			then
				var=$currentDir
				break
			else
				continue
			fi
		done
		if [ $var == $currentDir ]
		then
			currentDir=$currentDir/android
		else
			echo "You are not in an android product dir, Please check"
			return 0
		fi
	fi

	if [[ $currentDir =~ "android" ]]
	then
		first=${currentDir%%android*}android
		last=${currentDir%android*}android
	elif [[ $currentDir =~ "modem" ]]
	then
		first=${currentDir%%modem*}android
		last=${currentDir%modem*}android
	elif [[ $currentDir =~ "alps" ]]
	then
		first=${currentDir%%alps*}alps
		last=${currentDir%alps*}alps
	fi 

	if [ ${first} != ${last} ]
	then
		read option
		if [ -z "${option}" ]
		then 
			:
		else
			first=${last}
		fi
	fi
	
	case ${1%%/*} in
	"modem")
		first=${first}/../$1
		;;
	"dts")
		first=${first}/kernel/arch/arm/boot/$1
		;;
	"dts64")
		first=${first}/kernel/arch/arm64/boot/dts
		;;
	"qcom")
		if [ -d ${first}/kernel/arch/arm/boot/dts/qcom ]; then
			first=${first}/kernel/arch/arm/boot/dts/qcom
		elif [ -d ${first}/kernel/msm-3.18/arch/arm/boot/dts/qcom ]; then
			first=${first}/kernel/msm-3.18/arch/arm/boot/dts/qcom
		fi
		;;
	"qcom64")
		if [ -d ${first}/kernel/arch/arm64/boot/dts/qcom ]; then
			first=${first}/kernel/arch/arm64/boot/dts/qcom
		elif [ -d ${first}/kernel/msm-3.18/arch/arm64/boot/dts/qcom ]; then
			first=${first}/kernel/msm-3.18/arch/arm64/boot/dts/qcom
		fi
		;;
	"power")
		first=${first}/kernel/drivers/$1
		;;
	"lk")
		first=${first}/bootable/bootloader/$1
		;;
	"obj")
		first=${first}/out/target/product/*/$1
		;;
	"android")
		;;
	*)
		first=${first}/$1
		;;
	esac

	cd ${first}
}
!
function _makeAndroid
{
	#local opts="zt40a62 LS_5504 zx55q05_64 angus3A41 angus3A4 angus3A5 angus3T3"
	if [ ! -f build/core/envsetup.mk ]; then
		echo "You are not in an Android project"
		return
	fi
	local opts="$(ls device/qcom/)"
	local opts2="user userdebug eng"
	_completeFunc "$opts" 1 "$opts2" 2
}

function mAndroid
{
	local variant="userdebug"
	if [ ! -z $2 ]
	then
		variant=$2
	fi
	if [ -f build/core/envsetup.mk ]
	then
		if [ -z $1 ]
		then
			echo "You did not choose any project yet!"
			return 
		fi
		echo "source ./build/envsetup.sh"
		source ./build/envsetup.sh
		if [ $1x = "zx55q05_64"x -o $1x = "LS_5504"x ]
		then 
			echo "choosecombo 1 $1 $variant 1"
			choosecombo 1 $1 $variant 1
		else
			echo "choosecombo 1 $1 $variant"
			choosecombo 1 $1 $variant
		fi
	else 
		echo "You are not in android project!"
	fi
}

function _makeimage
{
	local opts="bootimage aboot systemimage recoveryimage otapackage update-api vendorimage"
	local opts2="-j8 -j16 -j32"
	_completeFunc "$opts" 1 "$opts2" 2
}

function mImage
{
	local _jn="-j16"
	if [ ! -z $2 ]
	then
		_jn=$2
	fi
	echo "make $1 $_jn `date "+%Y%m%d %H:%M:%S"` start"
	case $1 in
		"all")
		make $_jn
		;;
		bootimage|aboot|systemimage|recoveryimage|otapackage|update-api|vendorimage)
		make $1 $_jn
		;;
		*)
		echo "Check $1!"
		return 
	esac
	echo "make $1 $_jn `date "+%Y%m%d %H:%M:%S"` end"
}

alias mHistoryGrep='
function _mHistoryGrep()
{ 
	if [ "x$2" == "x" ]; then 
		local n=10 
	else 
		n=$2 
	fi 
	history | grep $1 | tail -n $n 
	unset -f _mHistoryGrep 
} 
_mHistoryGrep'

function _mGrep()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ ${COMP_CWORD} -eq 1 ]
	then
		local opts="`ls ~/.bin/`"
		COMPREPLY=($(compgen -W "$opts" -- $cur))
		return 0
	fi
}

alias dtsParse='
function _parseDts()
{ 
	if [ "x$2" == "x" ]; then 
		~/.bin/parseDts.py $1
	else 
		~/.bin/parseDts.py $1 | xargs grep --color=auto -n $2
	fi 
	unset -f _parseDts
} 
_parseDts'

function _dtsParse()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ ${COMP_CWORD} -eq 1 ]
	then
		local opts="`ls *-mtp*`"
		COMPREPLY=($(compgen -W "$opts" -- $cur))
		return 0
	fi
}

function _repo()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ ${COMP_CWORD} -eq 1 ]
	then 
		local opts="start branches checkout diff stage prune abandon status sync init remote push forall grep manifest version upload download selfupdate"
		COMPREPLY=($(compgen -W "$opts" -- $cur))
		return 0
	fi
}

function _cat_file
{
	for var in `ls`
	do
		if [ -L $var ]
		then
			continue
		elif [ -d $var ]
		then
			(cd $var; if [ $? -ne 0 ]; then continue; fi; _cat_file;)
		elif [ -f $var ]
		then
			if [ ${var##*.} = "c" -o ${var##*.} = "cc" -o ${var##*.} = "cpp" -o ${var##*.} = "java" ]
			then
				cat $var > ${var%.*}.diff
				rm $var
				mv ${var%.*}.diff ${var}
			fi
		fi
	done
	echo -e; echo `pwd`;
}

function Analyse()
{
	if [ ! $# -eq 1 ]; then
		echo "Usage: $0 Dir"
	elif [ -L $1 ]; then
		echo "Notice: $1 is a link file!"
		echo "Are you sure you want to analyse $1(Y/n):"
		read input
		if [[ $input == "Y" || $input == "y" ]]; then
			echo "You are choosing to go on analysing $1"
			cd $1
			if [ $? -ne 0 ]; then 
				echo "$1 is not a Dir link"
			else 
				_cat_file
			fi
		else
			echo "You give up analysing $1"
		fi
	elif [ -f $1 ]; then
		echo "NOTICE:$1 is a file!"
		if [ ${1##*.} = "c" -o ${1##*.} = "cc" -o ${1##*.} = "cpp" -o ${1##*.} = "java" ]
		then
			cat $1 > ${1%.*}.diff
			rm $1
			mv ${1%.*}.diff ${1}
			echo "NOTICE:$1 is analysed!"
		fi
	elif [ -d $1 ]; then
		cd $1
		if [ $? -ne 0 ]; then
			echo "We can't enter $1, please check what $1 is!"
		else
			_cat_file
		fi
	else
		echo "NOTICE: We can not find $1, please make sure it exist!"
	fi
}

function autoDir()
{
	~/.bin/autoDir.py $1
}

function _download()
{
	local opts="boot aboot system userdata tz devcfg"
	_completeFunc "$opts" 1
}

function Download()
{
	#adb wait-for-device; adb reboot bootloader
	adb reboot bootloader
	case $1 in
		"devcfg" | "tz")
			fastboot flash $1 $1.mbn
			;;
		"aboot")
			fastboot flash $1 emmc_appsboot.mbn
			;;
		*)
			fastboot flash $1 $1.img
			;;
	esac
	fastboot reboot
}

complete -F _mGrep mHistoryGrep
complete -F _cAndroid Cd
complete -F _mkDir mkSingleDir.py
complete -F _getGitLog getGitLog.py
complete -F _makeAndroid mAndroid
complete -F _makeimage mImage
complete -F _dtsParse dtsParse
complete -F _repo repo
complete -F _download Download
complete -f -d Analyse
complete -f -d autoDir 
