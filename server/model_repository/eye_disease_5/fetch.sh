#/bin/sh

BASEDIR=$(dirname "$0")

curl -L -z $BASEDIR/1/model.onnx -o $BASEDIR/1/model.onnx https://github.com/pal-ette/iPetPal/releases/download/model-7/eye_all_ttv_au_under_250000_5class.onnx
curl -L -z $BASEDIR/eye_disease_5.txt -o $BASEDIR/eye_disease_5.txt https://github.com/pal-ette/iPetPal/releases/download/model-7/eye_all_ttv_au_under_250000_5class.txt
