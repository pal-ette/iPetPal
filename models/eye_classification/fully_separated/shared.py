import torch
import timm
import os
import onnxruntime
from scipy.special import softmax
from PIL import Image
from torchvision.transforms import (
    Compose,
    ToTensor,
    RandomHorizontalFlip,
    RandomVerticalFlip,
    Normalize,
)


def load_dict(model, optimizer, dict_file):
    pretrained = torch.load(dict_file)

    epoch = pretrained["epoch"]
    state_dict = pretrained["state_dict"]
    opt_dict = pretrained["optimizer"]
    labels = pretrained["label"]

    model_dict = model.state_dict()
    model_dict.update(state_dict)
    model.load_state_dict(model_dict)

    optimizer.load_state_dict(opt_dict)

    return epoch, labels, model, optimizer


def to_numpy(tensor):
    return (
        tensor.detach().cpu().numpy() if tensor.requires_grad else tensor.cpu().numpy()
    )


def get_model(model_name, num_classes):
    return timm.create_model(model_name, pretrained=True, num_classes=num_classes)


def get_optimizer(model):
    return torch.optim.SGD(model.parameters(), lr=0.01, weight_decay=1e-5, momentum=0.9)


def get_label(pt_path):
    label_file = open(f"{os.path.dirname(pt_path)}/label.txt", "r", encoding="utf8")
    out_labels = [line.strip() for line in label_file]
    label_file.close()
    return out_labels


transforms = Compose(
    [
        ToTensor(),
        RandomHorizontalFlip(),
        RandomVerticalFlip(),
    ]
)