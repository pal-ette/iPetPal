import os
import glob
import shutil
import tqdm
from pathlib import Path
from shared import desease_to_english

if __name__ == "__main__":
    deploy_path = "deploy"
    os.makedirs(deploy_path, exist_ok=True)

    for onnx_path in tqdm.tqdm(glob.glob(f"working\\*\\*.onnx")):
        model_name = Path(onnx_path).stem
        _, desease = os.path.split(os.path.dirname(onnx_path))
        shutil.copyfile(
            onnx_path, f"{deploy_path}\\{desease_to_english(desease)}_{model_name}.onnx"
        )

    for label_file in tqdm.tqdm(glob.glob(f"working\\*\\label.txt")):
        _, desease = os.path.split(os.path.dirname(label_file))
        shutil.copyfile(label_file, f"{deploy_path}\\{desease_to_english(desease)}.txt")
