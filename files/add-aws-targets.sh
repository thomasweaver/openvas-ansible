#!/bin/bash

AWS_INSTANCES_OUTPUT=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId, IP:PrivateIpAddress, Public_IP :PublicIpAddress}" --filter "Name=instance-state-code,Values=16" --output text)

ORIG_IFS=$IFS

IFS="
"

OPENVAS_XML="<create_target><name>Scan Targets</name><hosts>"

HOSTS_XML=""

for instance in $AWS_INSTANCES_OUTPUT; do
        ID=$(echo $instance | awk '{ print $1; }')
        PRIVATE_IP=$(echo $instance | awk '{ print $2; }')
        PUBLIC_IP=$(echo $instance | awk '{ print $3; }')

        echo "Instance: ${ID}, PrivateIP: ${PRIVATE_IP}, PublicIP: ${PUBLIC_IP}"

        if [ "$PUBLIC_IP" != "None" ]; then
                HOSTS_XML="${HOSTS_XML},${PRIVATE_IP},${PUBLIC_IP}"
        else
                HOSTS_XML="${HOSTS_XML},${PRIVATE_IP}"
        fi
done

HOSTS_XML=$(echo $HOSTS_XML | sed 's/^,\|,$//g')

OPENVAS_XML="${OPENVAS_XML}${HOSTS_XML}</hosts></create_target>"

echo $OPENVAS_XML

IFS=$ORIG_IFS
