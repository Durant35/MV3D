#!/bin/bash
# Usage:
# ./experiments/scripts/mv3d.sh $DEVICE $DEVICE_ID PRE_TRAINED-MODEL kitti_train
#
# Example:
# ./experiments/scripts/mv3d.sh gpu 0 data/pretrain_model/VGG_imagenet.npy kitti_train

set -x
set -e

export PYTHONUNBUFFERED="True"

DEV=$1
DEV_ID=$2
WEIGHTS=$3
DATASET=$4

array=( $@ )
len=${#array[@]}
EXTRA_ARGS=${array[@]:4:$len}
EXTRA_ARGS_SLUG=${EXTRA_ARGS// /_}


mkdir -p experiments/logs
LOG="experiments/logs/mv3d.txt.`date +'%Y-%m-%d_%H-%M-%S'`"
exec &> >(tee -a "$LOG")
echo Logging output to "$LOG"

time python ./tools/train_net.py --device ${DEV} --device_id ${DEV_ID} \
  --weights ${WEIGHTS} \
  --imdb ${DATASET} \
  --iters 50001 \
  --cfg experiments/cfgs/faster_rcnn_end2end.yml \
  --network MV3D_train \
  ${EXTRA_ARGS}

set +x
NET_FINAL=`grep -B 1 "done solving" ${LOG} | grep "Wrote snapshot" | awk '{print $4}'`
set -x

time python ./tools/test_net.py --device ${DEV} --device_id ${DEV_ID} \
  --weights ${WEIGHTS} \
  --imdb ${DATASET}\
  --cfg experiments/cfgs/faster_rcnn_end2end.yml \
  --network MV3D_test \
  ${EXTRA_ARGS}

