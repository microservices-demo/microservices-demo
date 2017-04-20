#!/bin/bash

set -eu

AWS_BUILDS=('us-west-2,ami-746aba14')

ORIG_DIR=`pwd`
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# ------------------------------------------------------------

# check 'packer' is present
if [ ! `command -v packer` ]; then
  echo "'packer' is required but not found!"
  exit 1
fi

# ------------------------------------------------------------
# util functions
invoke_packer() {

  REGION="$1"
  BASE_AMI="$2"

  PACKER_VARS="-var ami_groups=${AMI_GROUPS:-all} -var aws_region=${REGION} -var aws_base_ami=${BASE_AMI}"

  echo "PACKER_VARS: $PACKER_VARS"

  packer validate $PACKER_VARS packer-template.json && \
  echo "Validated OK" && \
  packer build -force $PACKER_VARS packer-template.json 2>&1 &

}
# ------------------------------------------------------------
# execute packer for each region & base AMI
AMI_GROUPS="${AMI_GROUPS:-all}"

for BUILD in $AWS_BUILDS; do

  array=(${BUILD//,/ })

  AWS_REGION="${array[0]}"
  AWS_BASE_AMI="${array[1]}"

  invoke_packer $AWS_REGION $AWS_BASE_AMI

done

# ------------------------------------------------------------
# wait for all to finish

echo "Waiting for builds to finish..."

wait

echo "Done."

cd $ORIG_DIR