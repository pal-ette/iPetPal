#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-1/skin_eye_resnet.onnx
