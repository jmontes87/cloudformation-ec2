read_allowed_values() {
    PARAM_NAME=$1
    ALLOWED_VALUES=$(awk -v param="$PARAM_NAME" '/^[[:space:]]*#/{next}/^ *'"$PARAM_NAME"':/{p=1;next} p && /AllowedValues/{p=0;getline;gsub(/^[[:space:]]*-[[:space:]]*/,""); print}' index.yml)
    if [ -z "$ALLOWED_VALUES" ]; then
        echo "no suggestions"
        exit 1
    fi
    echo "$ALLOWED_VALUES"
}

read_parameter() {
    PARAM_NAME=$1
    ALLOWED_VALUES=$(read_allowed_values $PARAM_NAME)
    read -p "$PARAM_NAME $ALLOWED_VALUES: " PARAM_VALUE
    echo $PARAM_VALUE
}

STACK_NAME=$(read_parameter "StackName")
AVAILABILITY_ZONE=$(read_parameter "AvailabilityZone")
INSTANCE_TYPE=$(read_parameter "InstanceType")
INSTANCE_STORAGE_SIZE=$(read_parameter "InstanceStorageSize")
ENVIRONMENT=$(read_parameter "Environment")