#!/sbin/busybox sh

BB=/sbin/busybox;

case "$1" in
	CPUFrequencyList)
		for CPUFREQ in `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`; do
		LABEL=$((CPUFREQ / 1000));
			$BB echo "$CPUFREQ:\"${LABEL} MHz\", ";
		done;
	;;
	CPUGovernorList)
		for CPUGOV in `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`; do
			$BB echo "\"$CPUGOV\",";
		done;
	;;
	DebugPVS)
		$BB echo "ACPU PVS";
	;;	
	Thermalzone)
		z0=`cat /sys/class/thermal/thermal_zone0/temp`;
		z5=`cat /sys/class/thermal/thermal_zone5/temp`;
		z6=`cat /sys/class/thermal/thermal_zone6/temp`;
		z7=`cat /sys/class/thermal/thermal_zone7/temp`;
		z8=`cat /sys/class/thermal/thermal_zone8/temp`;
		tztemp="`$BB printf "%50s°C\n" "SOC0(0):${z0}" @n"CPU0(5):${z5}" @n"CPU1(6):${z6}" @n"CPU2(7):${z7}" @n"CPU3(8):${z8}" `";
		$BB echo "${tztemp}";
	;;
	DebugSPEED)
		$BB echo "SPEED BIN";
	;;
	DefaultCPUBWGovernor)
		if [ -d /sys/class/devfreq/qcom,cpubw.* ]; then
			$BB echo "`$BB cat /sys/class/devfreq/qcom,cpubw.*/governor`"
		fi
	;;
	DefaultCPUL2Governor)
		if [ -d /sys/class/devfreq/qcom,cache.* ]; then
			$BB echo "`$BB cat /sys/class/devfreq/qcom,cache.*/governor`"
		fi
	;;
	DefaultCPUFrequency)
		CPU0_FREQMAX="$(expr `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq` / 1000)MHz";
		CPU0_FREQMIN="$(expr `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq` / 1000)MHz";
		echo "CPU最大频率: $CPU0_FREQMAX@nCPU最小频率: $CPU0_FREQMIN"
	;;
	DefaultCPUCURFrequency)
		CPU0_FREQCUR="$(expr `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` / 1000)MHz";
		if [ -e /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq ];then
			CPU1_FREQCUR="$(expr `cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq` / 1000)MHz";
			else 
			CPU1_FREQCUR=`echo "休眠"`;
		fi
		if [ -e /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq ];then
			CPU2_FREQCUR="$(expr `cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq` / 1000)MHz";
			else 
			CPU2_FREQCUR=`echo "休眠"`;
		fi
		if [ -e /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq ];then
			CPU3_FREQCUR="$(expr `cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq` / 1000)MHz";
			else 
			CPU3_FREQCUR=`echo "休眠"`;
		fi
		$BB echo "CPU0核心: ${CPU0_FREQCUR}@nCPU1核心: ${CPU1_FREQCUR}@nCPU2核心: ${CPU2_FREQCUR}@nCPU3核心: ${CPU3_FREQCUR}";
	;;
	LiveThermalstats)
		Thermal=/sys/module/msm_thermal/parameters;
		serveron=`pgrep -f "/system/bin/thermal-engine" | wc -l`;
		intelli_enabled=`$BB cat ${Thermal}/intelli_enabled`;
		sensor_id=`$BB cat ${Thermal}/sensor_id`;
		limit_temp_degC=`$BB cat ${Thermal}/limit_temp_degC`;
		limit_safe_temp_degC=`$BB cat ${Thermal}/limit_safe_temp_degC`;
		temp_hysteresis_degC=`$BB cat ${Thermal}/temp_hysteresis_degC`;
		temp=`cat /sys/class/thermal/thermal_zone${sensor_id}/temp`;
		if [ ${intelli_enabled} == "Y" ];then
			UPT=`expr ${limit_temp_degC} - ${temp_hysteresis_degC}`;
			if [ "${temp}" -gt "${UPT}" ];then
				UT="升频偏移值：$(expr ${temp} - ${UPT} )ºC";
				else
				UT=`echo "设备全速运行！"`;
			fi
			if [ "${temp}" -ge "${limit_temp_degC}" ];then
				DLST="$(expr ${limit_safe_temp_degC} - ${temp})ºC";
				Thermalstats="已触发智能温控@n距离极限降频还有：${DLST}@n${UT}";
			else
				Thermalstats=`$BB echo "目前未触发温控@nIntelli温控监视中@n${UT}"`;
			fi
		else
			Thermalstats=`$BB echo "Intelli智能温控未运行"`;
		fi
		if [ ${serveron} == 1 ];then
			THSS=`$BB echo "高通温控服务运行中"`;
			else
			THSS=`$BB echo "高通温控服务已关闭"`;
		fi;
		$BB echo "${THSS}@n${Thermalstats}";
	;;
	DefaultGPUGovernor)
		$BB echo "`$BB cat /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/governor`"
	;;
	DirKernelIMG)
		$BB echo "/dev/block/platform/msm_sdcc.1/by-name/boot";
	;;
	DirCPUGovernor)
		$BB echo "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor";
	;;
	DirCPUGovernorTree)
		$BB echo "/sys/devices/system/cpu/cpufreq";
	;;
	DirCPUMaxFrequency)
		$BB echo "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq";
	;;
	DirCPUMinFrequency)
		$BB echo "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq";
	;;
	DirGPUGovernor)
		$BB echo "/sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/governor";
	;;
	DirGPUMaxFrequency)
		$BB echo "/sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/max_freq";
	;;
	DirGPUMinPwrLevel)
		$BB echo "/sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/min_freq";
	;;
	DirGPUNumPwrLevels)
		$BB echo "/sys/class/kgsl/kgsl-3d0/num_pwrlevels";
	;;
	DirIOReadAheadSize)
		$BB echo "/sys/block/mmcblk0/queue/read_ahead_kb";
	;;
	DirIOScheduler)
		$BB echo "/sys/block/mmcblk0/queue/scheduler";
	;;
	DirIOSchedulerTree)
		$BB echo "/sys/block/mmcblk0/queue/iosched";
	;;
	DirTCPCongestion)
		$BB echo "/proc/sys/net/ipv4/tcp_congestion_control";
	;;
	GPUFrequencyList)
		for GPUFREQ in `$BB cat /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/available_frequencies` ; do
		LABEL=$((GPUFREQ / 1000000));
			$BB echo "$GPUFREQ:\"${LABEL} MHz\", ";
		done;
	;;
	GPUGovernorList)
		for GPUGOV in `$BB cat /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/available_governors`; do
			$BB echo "\"$GPUGOV\",";
		done;
	;;
	GPUPowerLevel)
		for GPUFREQ in `$BB cat /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/available_frequencies` ; do
		LABEL=$((GPUFREQ / 1000000));
			$BB echo "$GPUFREQ:\"${LABEL} MHz\", ";
		done;
	;;
	IOSchedulerList)
		for IOSCHED in `$BB cat /sys/block/mmcblk0/queue/scheduler | $BB sed -e 's/\]//;s/\[//'`; do
			$BB echo "\"$IOSCHED\",";
		done;
	;;
	LiveBatteryTemperature)
		BAT_C=`$BB awk '{ print $1 / 10 }' /sys/class/power_supply/battery/temp`;
		BAT_F=`$BB awk "BEGIN { print ( ($BAT_C * 1.8) + 32 ) }"`;
		BAT_H=`$BB cat /sys/class/power_supply/battery/health`;

		$BB echo "$BAT_C°C | $BAT_F°F@nHealth: $BAT_H";
	;;
	LiveCPUL2Frequency)
		if [ -d /sys/class/devfreq/qcom,cache.* ]; then
			CPUL2FREQ="$((`$BB cat /sys/class/devfreq/qcom,cache.*/cur_freq` / 1000000)) MHz";
		fi
		$BB echo "$CPUL2FREQ";
	;;
	LiveCPUBWFrequency)
		if [ -d /sys/class/devfreq/qcom,cpubw.* ]; then
			CPUBWFREQ="$((`$BB cat /sys/class/devfreq/qcom,cpubw.*/cur_freq` / 1000000)) MHz";
		fi
		$BB echo "$CPUBWFREQ";
	;;
	LiveCPUTemperature)
		CPU_C=`$BB cat /sys/class/thermal/thermal_zone5/temp`;
		CPU_F=`$BB awk "BEGIN { print ( ($CPU_C * 1.8) + 32 ) }"`;

		$BB echo "$CPU_C°C";
	;;
	LiveSOCTemperature)
		SOC_C=`$BB cat /sys/class/thermal/thermal_zone1/temp`;
		SOC_F=`$BB awk "BEGIN { print ( ($CPU_C * 1.8) + 32 ) }"`;

		$BB echo "$SOC_C°C";
	;;
	LiveGPUFrequency)
		GPUFREQ="$((`$BB cat /sys/devices/fdb00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/gpuclk` / 1000000)) MHz";
		$BB echo "$GPUFREQ";
	;;
	LiveMemory)
		while read TYPE MEM KB; do
			if [ "$TYPE" = "MemTotal:" ]; then
				TOTAL="$((MEM / 1024)) MB";
			elif [ "$TYPE" = "MemFree:" ]; then
				CACHED=$((MEM / 1024));
			elif [ "$TYPE" = "Cached:" ]; then
				FREE=$((MEM / 1024));
			fi;
		done < /proc/meminfo;

		FREE="$((FREE + CACHED)) MB";
		$BB echo "Total: $TOTAL@nFree: $FREE";
	;;
	LiveTime)
		STATE="";
		CNT=0;
		SUM=`$BB awk '{s+=$2} END {print s}' /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state`;

		while read FREQ TIME; do
			if [ "$CNT" -ge $2 ] && [ "$CNT" -le $3 ]; then
				FREQ="$((FREQ / 1000)) MHz:";
				if [ $TIME -ge "100" ]; then
					PERC=`$BB awk "BEGIN { print ( ($TIME / $SUM) * 100) }"`;
					PERC="`$BB printf "%0.1f\n" $PERC`%";
					TIME=$((TIME / 100));
					STATE="$STATE $FREQ `$BB echo - | $BB awk -v "S=$TIME" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'` ($PERC)@n";
				fi;
			fi;
			CNT=$((CNT+1));
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		STATE=${STATE%??};
		$BB echo "$STATE";
	;;
	LiveUpTime)
		TOTAL=`$BB awk '{ print $1 }' /proc/uptime`;
		AWAKE=$((`$BB awk '{s+=$2} END {print s}' /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state` / 100));
		SLEEP=`$BB awk "BEGIN { print ($TOTAL - $AWAKE) }"`;

		PERC_A=`$BB awk "BEGIN { print ( ($AWAKE / $TOTAL) * 100) }"`;
		PERC_A="`$BB printf "%0.1f\n" $PERC_A`%";
		PERC_S=`$BB awk "BEGIN { print ( ($SLEEP / $TOTAL) * 100) }"`;
		PERC_S="`$BB printf "%0.1f\n" $PERC_S`%";

		TOTAL=`$BB echo - | $BB awk -v "S=$TOTAL" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		AWAKE=`$BB echo - | $BB awk -v "S=$AWAKE" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		SLEEP=`$BB echo - | $BB awk -v "S=$SLEEP" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		$BB echo "Total: $TOTAL (100.0%)@nSleep: $SLEEP ($PERC_S)@nAwake: $AWAKE ($PERC_A)";
	;;
	LiveUnUsed)
		UNUSED="";
		while read FREQ TIME; do
			FREQ="$((FREQ / 1000)) MHz";
			if [ $TIME -lt "100" ]; then
				UNUSED="$UNUSED$FREQ, ";
			fi;
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		UNUSED=${UNUSED%??};
		$BB echo "$UNUSED";
	;;
	LiveWakelocksKernel)
		WL="";
		CNT=0;
		PATH=/sdcard/wakelocks.txt;
		$BB sort -nrk 7 /proc/wakelocks > $PATH;

		while read NAME COUNT EXPIRE_COUNT WAKE_COUNT ACTIVE_SINCE TOTAL_TIME SLEEP_TIME MAX_TIME LAST_CHANGE; do
			if [ $CNT -lt 10 ]; then
				NAME=`$BB echo $NAME | $BB sed 's/PowerManagerService./PMS./;s/"//g'`
				TIME=`$BB awk "BEGIN { print ( $SLEEP_TIME / 1000000000 ) }"`;
				TIME=`$BB echo - | $BB awk -v "S=$TIME" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
				WL="$WL$NAME: $TIME@n";
			fi;
			CNT=$((CNT+1));
		done < $PATH;
		$BB rm -f $PATH;

		WL=${WL%??};
		$BB echo $WL;
	;;
	MaxCPU)
		$BB echo "4";
	;;
	MinFreqIndex)
		ID=0;
		MAXID=8;
		while read FREQ TIME; do
			LABEL=$((FREQ / 1000));
			if [ $FREQ -gt "384000" ] && [ $ID -le $MAXID ]; then
				MFIT="$MFIT $ID:\"${LABEL} MHz\", ";
			fi;
			ID=$((ID + 1));
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		$BB echo $MFIT;
	;;
	SetCPUBWGovernor)
		if [[ ! -z $3 ]]; then
			$BB echo $3 > $2 2> /dev/null;
		fi;

		$BB echo `$BB cat $2`;
	;;
	SetCPUGovernor)
		for CPU in /sys/devices/system/cpu/cpu[1-3]; do
			$BB echo 1 > $CPU/online;
			$BB echo $2 > $CPU/cpufreq/scaling_governor;
		done;
	;;
	SetCPUMaxFrequency)
		for CPU in /sys/devices/system/cpu/cpu[1-3]; do
			$BB echo 1 > $CPU/online;
			$BB echo $2 > $CPU/cpufreq/scaling_max_freq;
		done;
	;;
	SetCPUMinFrequency)
		for CPU in /sys/devices/system/cpu/cpu[1-3]; do
			$BB echo 1 > $CPU/online;
			$BB echo $2 > $CPU/cpufreq/scaling_min_freq;
		done;
	;;
	SetGPUMinPwrLevel)
		if [[ ! -z $3 ]]; then
			$BB echo $3 > $2;
		fi;

		$BB echo `$BB cat $2`;
	;;
	SetGPUGovernor)
		if [[ ! -z $3 ]]; then
			$BB echo $3 > $2 2> /dev/null;
		fi;

		$BB echo `$BB cat $2`;
	;;
	TCPCongestionList)
		for TCPCC in `$BB cat /proc/sys/net/ipv4/tcp_available_congestion_control` ; do
			$BB echo "\"$TCPCC\",";
		done;
	;;
	LiveDefaultCPUGovernor)
		cpugov_show=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor);
		echo "$cpugov_show";
	;;
	LiveCPU_HOTPLUG)
		if [ "$(cat /sys/kernel/alucard_hotplug/hotplug_enable)" -eq "1" ]; then
			ALUCARD_HOTPLUG=活动;
		else
			ALUCARD_HOTPLUG=关闭;
		fi;
		if [ "$(cat /sys/kernel/msm_mpdecision/conf/enabled)" -eq "1" ]; then
			MSM_MPDECISION=活动;
		else
			MSM_MPDECISION=关闭;
		fi;
		$BB echo "Alucard HotPlug: $ALUCARD_HOTPLUG@nMSM BRICKD: $MSM_MPDECISION"
	;;
	LivePVSbin)
		pvs_bin=`$BB cat /sys/devices/soc0/pvs_bin`;
	$BB echo "PVS:${pvs_bin}";
	;;
esac;
