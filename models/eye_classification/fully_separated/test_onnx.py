import onnx
import onnxruntime
import glob
import os
from scipy.special import softmax
from shared import load_dict, get_model, get_optimizer, get_label
from PIL import Image
from torchvision.transforms import (
    ToTensor,
    Normalize,
)
from pathlib import Path
from sklearn.metrics import confusion_matrix
import seaborn as sns

if __name__ == "__main__":
    import matplotlib.font_manager as font_manager
    import matplotlib.pyplot as plt

    font_files = font_manager.findSystemFonts(fontpaths="D:\CVProject\D2Coding")
    for font_file in font_files:
        font_manager.fontManager.addfont(font_file)

    plt.rc("font", family="D2Coding")

    base_path = "D:\CVProject\개_안구_resized_train_test"
    for desease in os.listdir(base_path):
        if not desease.endswith("_test"):
            continue
        desease_name = desease.replace("_test", "")
        labels = get_label(f"working\\{desease_name}\\")
        test_datas = [
            (path, labels.index(os.path.split(os.path.dirname(path))[1]))
            for path in glob.glob(f"{base_path}\\{desease}\\*\\*")
        ]

        for onnx_path in glob.glob(f"working\\{desease_name}\\*.onnx"):
            model_name = Path(onnx_path).stem
            onnx_model = onnx.load(onnx_path)
            onnx.checker.check_model(onnx_model)

            ort_session = onnxruntime.InferenceSession(onnx_path)
            input_name = ort_session.get_inputs()[0].name

            predictions = {"target": [], "pred": [], "probs": []}
            for img_path, label in test_datas:

                img = Image.open(img_path)
                img = img.resize((224, 224))
                img = ToTensor()(img).unsqueeze(0)

                ort_inputs = {input_name: img.numpy()}
                ort_outs = ort_session.run(None, ort_inputs)

                result = softmax(ort_outs)
                predictions["target"].append(label)
                predictions["pred"].append(result[0][0].argmax())
                predictions["probs"].append(result[0][0].tolist())

            cm = confusion_matrix(
                predictions["target"],
                predictions["pred"],
                normalize="true",
            )
            hm = sns.heatmap(cm, annot=True, fmt=".2f", cmap="flare_r")
            hm.set_xlabel("Prediction", fontsize=10)
            hm.set_ylabel("True Label", fontsize=10)
            hm.set_xticklabels(
                labels=labels,
                fontsize=10,
                rotation=45,
                ha="right",
                rotation_mode="anchor",
            )
            hm.set_yticklabels(labels=labels, fontsize=10, rotation=0)
            fig = hm.get_figure()
            fig.savefig(
                os.path.join(
                    os.path.dirname(onnx_path),
                    f"{model_name}_test_hm.png",
                ),
            )
            fig.clf()
