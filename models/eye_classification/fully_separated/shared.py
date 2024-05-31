import os
import torch
import timm
import pickle
import matplotlib.pyplot as plt
from collections import OrderedDict
from torchvision.transforms import (
    ToTensor,
    Normalize,
    Compose,
    RandomHorizontalFlip,
    RandomVerticalFlip,
)


def desease_to_english(desease_name):
    map = {
        "결막염": "EYE01",
        "궤양성각막질환": "EYE02",
        "백내장": "EYE03",
        "비궤양성각막질환": "EYE04",
        "색소침착성각막염": "EYE05",
        "안검내반증": "EYE06",
        "안검염": "EYE07",
        "안검종양": "EYE08",
        "유루증": "EYE09",
        "핵경화": "EYE10",
    }

    return map[desease_name]


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


def calc_accuracy(X, Y):
    max_vals, max_indices = torch.max(X, 1)
    train_acc = (max_indices == Y).sum().data.cpu().numpy() / max_indices.size()[0]
    return train_acc


def save_checkpoint(
    epoch,
    labels,
    model,
    optimizer,
    train_loss_epoch,
    val_loss_epoch,
    train_acc_epoch,
    val_acc_epoch,
    model_path,
    filename,
):

    model_dict = OrderedDict([(k, v) for k, v in model.state_dict().items()])
    state = {
        "epoch": epoch,
        "state_dict": model_dict,
        "optimizer": optimizer.state_dict(),
        "label": labels,
    }
    torch.save(state, os.path.join(model_path, f"{filename}.pt"))

    config = {
        "train": {"acc": train_acc_epoch, "loss": train_loss_epoch},
        "valid": {"acc": val_acc_epoch, "loss": val_loss_epoch},
    }

    with open(os.path.join(model_path, f"{filename}.pickle"), "wb") as fw:
        pickle.dump(config, fw)


def load_records(pkl_file):
    with open(pkl_file, "rb") as f:
        records = pickle.load(f)
    return records["train"], records["valid"]


def loss_epoch_curve(
    model_path,
    filename,
    train_loss_epoch,
    val_loss_epoch,
    train_acc_epoch,
    val_acc_epoch,
):
    figure, ax = plt.subplots(1, 2, figsize=(12, 5))

    ax[0].plot(train_loss_epoch)
    ax[0].plot(val_loss_epoch)
    ax[0].set_title("Loss-Epoch curve")
    ax[0].set_ylabel("Loss")
    ax[0].set_xlabel("Epoch")
    ax[0].legend(["train", "val"], loc="upper right")

    ax[1].plot(train_acc_epoch)
    ax[1].plot(val_acc_epoch)
    ax[1].set_title("Model Accuracy")
    ax[1].set_ylabel("Accuracy")
    ax[1].set_xlabel("Epoch")
    ax[1].legend(["train", "val"], loc="lower right")

    plt.savefig(os.path.join(model_path, f"{filename}.png"))


def print_file_count(base_dir, depth=1, space=0):
    if depth == 0:
        return
    for group in os.listdir(base_dir):
        group_path = f"{base_dir}\\{group}"
        print(
            "- " * space,
            group,
            f" ({len(os.listdir(group_path))})" if os.path.isdir(group_path) else "",
            sep="",
        )
        if os.path.isdir(group_path):
            print_file_count(group_path, depth - 1, space + 1)


transforms = Compose(
    [
        ToTensor(),
        RandomHorizontalFlip(),
        RandomVerticalFlip(),
    ]
)
