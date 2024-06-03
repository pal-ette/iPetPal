#/bin/sh

BASEDIR=$(dirname "$0")

# Skin or Eye binary classification
curl -L -z $BASEDIR/../assets/models/skin_eye_resnet.onnx -o $BASEDIR/../assets/models/skin_eye_resnet.onnx https://github.com/pal-ette/iPetPal/releases/download/model-3/skin_eye_resnet.onnx
curl -L -z $BASEDIR/../assets/labels/skin_eye.txt -o $BASEDIR/../assets/labels/skin_eye.txt https://github.com/pal-ette/iPetPal/releases/download/model-3/skin_eye_resnet.txt

# Skin disease or normal binary classification
curl -L -z $BASEDIR/../assets/models/skin_disease_normal.onnx -o $BASEDIR/../assets/models/skin_disease_normal.onnx https://github.com/pal-ette/iPetPal/releases/download/model-3/skin_binary_efficientnet.onnx
curl -L -z $BASEDIR/../assets/labels/skin_disease_normal.txt -o $BASEDIR/../assets/labels/skin_disease_normal.txt https://github.com/pal-ette/iPetPal/releases/download/model-3/skin_binary_efficientnet.txt
