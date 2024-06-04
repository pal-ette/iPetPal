#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -z $BASEDIR/1/model.onnx -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-5/Resnet_squared_all_4class_b64_e40.onnx
curl -L -z $BASEDIR/eye_disease_4.txt -o $BASEDIR/eye_disease_4.txt https://github.com/pal-ette/iPetPal/releases/download/model-5/Resnet_squared_all_4class_b64_e40.txt
