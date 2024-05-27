#/bin/sh

BASEDIR=$(dirname "$0")


curl -L -o $BASEDIR/../assets/models/resnet50-v2-7.onnx https://github.com/pal-ette/iPetPal/releases/download/model-1/resnet50-v2-7.onnx

curl -L -o $BASEDIR/../assets/models/skin_eye_resnet.onnx https://github.com/pal-ette/iPetPal/releases/download/model-1/skin_eye_resnet.onnx
