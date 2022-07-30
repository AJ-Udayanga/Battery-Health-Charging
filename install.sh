#!/usr/bin/env bash

clear

cat <<_EOF_
        #############################################
        #        Battery Health Charge              #
        #############################################


_EOF_

echo "press any key to continue"
read -r -n 1 -s
clear

# Varialbles

bat-check() {
    #checking for the battery name
    echo 'chacking for the battery name'
    echo ''

    sleep 1

    ls /sys/class/power_supply

    echo ''
    echo 'Please not down the above shown battery name. eg:- BAT0'

    echo
    echo 'Press Enter/Return to continue...'
    read -r -n 1 -s
    clear

    sleep 1

}

config() {
    #checking for the availability of the
    read -p 'Please enter the battery name here: ' batname

    #checking the availability of the charge_control_end_threshold file
    if [[ -f "/sys/class/power_supply/$batname/charge_control_end_threshold" ]]; then
        echo -e "\nGreat. Your hardware supports this feature. Lets move to the configurations."
        sleep 1

    else
        echo "Your hardware does not support this feature."
        echo "press any key to exit"
        read -r -n 1 -s
        exit 1
    fi

    # Checking availability of the service.
    if [[ -f "/etc/systemd/system/battery-charge-threshold.service" ]]; then
        echo -e "\nbattery-charge-threshold.service was found.\n"
        sleep 1

        cp /etc/systemd/system/battery-charge-threshold.service ~/Documents/battery-charge-threshold.service.bk
        echo -e "\nBackup file placed in the ~/Documents/battery-charge-threshold.service.bk directory."
    else
        echo "battery-charge-threshold.service is not found. Creating the new service file."
    fi

    echo -e "\npress any key to continue"
    read -r -n 1 -s
    clear

    # Copying config file template from the repository
    #sudo cp charge_control_end_threshold "/sys/class/power_supply/$batname/charge_control_end_threshold"
    echo ''
    cat charge_control_end_threshold | tee /etc/systemd/system/battery-charge-threshold.service
    echo ''

    clear
    read -p 'Please enter the threshold value you want to set( 60 / 80 / 100) : ' threshold

    #appending configurations to the file.
    echo -e "\nAppending configurations to the files"
    sudo sed -i -e "s/CHARGE_STOP_THRESHOLD/$threshold/g" /etc/systemd/system/battery-charge-threshold.service
    sudo sed -i -e "s/BATTERY_NAME/$batname/g" /etc/systemd/system/battery-charge-threshold.service
    sleep 1
}

start() {
    echo -e "\nEnabling and starting the service."
    sudo systemctl enable battery-charge-threshold.service
    sudo systemctl start battery-charge-threshold.service
}

reload() {
    echo -e "\nReload the configurations and the service"
    sudo systemctl daemon-reload
    sudo systemctl restart battery-charge-threshold.service
}
start-reload() {
    echo -e "\npress any key to continue"
    read -r -n 1 -s
    clear

    echo "Input 'S' to enale and start the service OR input 'R' to reload the configuration and restart the services."
    read -p "Answer: " answer

    case $answer in
    S)
        start
        ;;
    s)
        start
        ;;
    R)
        reload
        ;;
    r)
        reload
        ;;
    esac

}

# main function

bat-check
config
start-reload

# Verifying the threshold configurations
sleep 1
echo -e "\nBattery charging threshold has set to: "
cat "/sys/class/power_supply/$batname/charge_control_end_threshold"

echo -e "\nBattery is currently"
cat "/sys/class/power_supply/$batname/status"
