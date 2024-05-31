import torch
import glob
import os

from shared import load_dict, get_model, get_optimizer, get_label


if __name__ == "__main__":
    base_directory = "working"
    for model_path in glob.glob(f"{base_directory}/*/*.pt"):
        labels = get_label(model_path)
        model = get_model("resnet50", len(labels))
        optimizer = get_optimizer(model)
        target_path = model_path.replace(".pt", ".onnx")

        print(f"{model_path} into {target_path}")

        epoch_start, labels, model, optimizer = load_dict(model, optimizer, model_path)

        torch_input = torch.randn(1, 3, 224, 224)

        torch.onnx.export(
            model,  # 실행될 모델
            torch_input,  # 모델 입력값 (튜플 또는 여러 입력값들도 가능)
            target_path,  # 모델 저장 경로 (파일 또는 파일과 유사한 객체 모두 가능)
            export_params=True,  # 모델 파일 안에 학습된 모델 가중치를 저장할지의 여부
            opset_version=10,  # 모델을 변환할 때 사용할 ONNX 버전
            do_constant_folding=True,  # 최적화시 상수폴딩을 사용할지의 여부
            input_names=["input"],  # 모델의 입력값을 가리키는 이름
            output_names=["output"],
        )  # 모델의 출력값을 가리키는 이름
