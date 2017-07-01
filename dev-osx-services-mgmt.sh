#!/usr/local/bin/bash

# The script required Bash in version 4.+

mode=$1
selectedServiceName=$2

declare -A MICRO_SERVICES

JAVA_ARGS="-Xms256m -Xmx256m"

MICRO_SERVICES["eureka-server"]="eureka-server/build/libs/eureka-server.jar"
MICRO_SERVICES["product-catalog-service"]="product-catalog-service/build/libs/product-catalog-service.jar"
MICRO_SERVICES["customer-register-service"]="customer-register-service/build/libs/customer-register-service.jar"
MICRO_SERVICES["ordering-service"]="ordering-service/build/libs/ordering-service.jar"

function findProcessPID() {
    screen_PID=$(eval "screen -list | grep $1 | cut -f1 -d'.' | sed 's/\W//g'")
    if [ ! -z ${screen_PID} ]
    then
        echo $(ps -el | grep ${screen_PID} | grep /usr/bin/java | awk '{print $2}')
    fi
}

function killProcessByPID() {
    serviceName=$1
    PID=$(findProcessPID ${serviceName})
    if [ ! -z ${PID} ]
    then
        eval "kill -9 ${PID}"
    fi
}

function runMicroService() {
    eval "screen -d -m -S $1 java ${JAVA_ARGS} -jar $2"
}

if [ "$mode" == "start" ]
then
    for serviceName in "${!MICRO_SERVICES[@]}"; do runMicroService ${serviceName} ${MICRO_SERVICES[$serviceName]}; done
    eval "screen -list"
    echo "All services started"
elif [ "$mode" == "stop" ] && [ ! -z ${selectedServiceName} ]
then
    killProcessByPID ${selectedServiceName}
    eval "screen -wipe"
    echo "Stop service ${selectedServiceName}"
elif [ "$mode" == "stop" ]
then
    for serviceName in "${!MICRO_SERVICES[@]}"; do killProcessByPID ${serviceName}; done
    eval "screen -wipe"
    echo "Stop services"
fi