#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-1/resnet50-v2-7.onnx
