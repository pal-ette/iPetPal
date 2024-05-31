#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -z $BASEDIR/label.txt -o $BASEDIR/label.txt https://github.com/pal-ette/iPetPal/releases/download/model-2/EYE04.txt
curl -L -z $BASEDIR/1/model.onnx -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-2/EYE04_resnet50.onnx
