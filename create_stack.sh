read_allowed_values() {
    PARAM_NAME=$1
    ALLOWED_VALUES=$(awk -v param="$PARAM_NAME" '/^[[:space:]]*#/{next}/^ *'"$PARAM_NAME"':/{p=1;next} p && /AllowedValues/{p=0;getline;gsub(/^[[:space:]]*-[[:space:]]*/,""); print}' main.yaml)
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

echo "Available AWS profiles:"
aws configure list-profiles

read -p "Enter AWS PROFILE: " AWS_PROFILE

STACK_NAME=$(read_parameter "StackName")
AVAILABILITY_ZONE=$(read_parameter "AvailabilityZone")
INSTANCE_TYPE=$(read_parameter "InstanceType")
INSTANCE_STORAGE_SIZE=$(read_parameter "InstanceStorageSize")
ENVIRONMENT=$(read_parameter "Environment")
AWS_REGION=$(read_parameter "AWSRegion")

# cat main.yaml services/ec2.yaml services/eip.yaml services/ec2SecurityGroup.yaml services/ec2keyPair.yaml services/s3.yaml > combined_template.yaml

# Crear la pila de CloudFormation
aws cloudformation create-stack \
    --profile $AWS_PROFILE \
    --region $AWS_REGION \
    --stack-name $STACK_NAME \
    --template-body file://combined_template.yaml \
    --parameters \
        ParameterKey=AvailabilityZone,ParameterValue=$AVAILABILITY_ZONE \
        ParameterKey=InstanceType,ParameterValue=$INSTANCE_TYPE \
        ParameterKey=InstanceStorageSize,ParameterValue=$INSTANCE_STORAGE_SIZE \
        ParameterKey=Environment,ParameterValue=$ENVIRONMENT

# Verificar el estado de la creación de la pila
echo "Creating stack $STACK_NAME..."
aws cloudformation wait stack-create-complete --profile $AWS_PROFILE --region $AWS_REGION --stack-name $STACK_NAME
echo "Stack $STACK_NAME created successfully."