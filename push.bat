@echo off
taskkill /f /im adb.exe

:aaa
adb shell su -c "pkill com.af.synapse"
adb shell su -c "mount -o remount,rw /"
adb shell su -c "rm -R /storage/external_SD/res"
rd /s /q D:\\change
md D:\\change
xcopy /s /y change D:\\change
adb push D:\\change /storage/external_SD/res/synapse
rd D:\\change
adb shell su -c "rm /res/synapse/config.json"
adb shell su -c "rm /res/synapse/config.json.generate*"
adb shell su -c "rm /res/synapse/actions/*"
adb shell su -c "rm /res/synapse/files/*"
adb shell su -c "cp /storage/external_SD/res/synapse/config.json.generate* /res/synapse/"
adb shell su -c "chmod 0777 /res/synapse/config.json.generate*"
adb shell su -c "cp /storage/external_SD/res/synapse/actions/* /res/synapse/actions/"
adb shell su -c "chmod 0755 /res/synapse/actions/*"
adb shell su -c "cp /storage/external_SD/res/synapse/files/* /res/synapse/files/"
adb shell su -c "chmod 0777 /res/synapse/files/*"
adb shell su -c "./res/synapse/uci"
adb shell su -c "am start -a android.intent.action.MAIN -n com.af.synapse/.MainActivity > /dev/null;"
pause
goto aaa
