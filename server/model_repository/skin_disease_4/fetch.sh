#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -z $BASEDIR/1/model.onnx -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-6/skin_4classes.onnx
curl -L -z $BASEDIR/skin_disease_4.txt -o $BASEDIR/skin_disease_4.txt https://github.com/pal-ette/iPetPal/releases/download/model-6/skin_4classes.txt
