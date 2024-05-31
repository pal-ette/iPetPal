from datasets import load_dataset

import os
import shutil
import zipfile
import pandas as pd
from PIL import Image
import numpy as np

import matplotlib.pyplot as plt
from PIL import Image, UnidentifiedImageError
import torch
import torch.nn as nn
from torch.utils.data import Dataset
from torchvision import datasets, transforms

import timm
import tqdm

from collections import OrderedDict
import pickle

from shared import load_dict, transforms, get_model, get_optimizer


def calc_accuracy(X, Y):
    max_vals, max_indices = torch.max(X, 1)
    train_acc = (max_indices == Y).sum().data.cpu().numpy() / max_indices.size()[0]
    return train_acc


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


if __name__ == "__main__":
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    batch_size = 32

    base_path = "D:\CVProject\개_안구_resized_train_test"

    base_model_name = "resnet50"

    for desease in os.listdir(base_path):
        if not desease.endswith("_train"):
            continue
        print(desease, end=" / ")
        desease_path = f"{base_path}\{desease}"
        desease_name = desease.replace("_train", "")
        dataset = datasets.ImageFolder(desease_path, transforms)

        labels = dataset.classes
        print(f"len(dataset): {len(dataset)}, labels: {dataset.classes}")

        train_size = int(len(dataset) * 0.8)
        valid_size = len(dataset) - train_size

        model = get_model(base_model_name, len(labels))

        train_dataset, valid_dataset = torch.utils.data.random_split(
            dataset, [train_size, valid_size]
        )

        print(len(train_dataset), len(valid_dataset))

        train_loader = torch.utils.data.DataLoader(
            train_dataset, batch_size=batch_size, shuffle=True, num_workers=4
        )

        valid_loader = torch.utils.data.DataLoader(
            valid_dataset, batch_size=batch_size, shuffle=True, num_workers=4
        )

        # training

        optimizer = get_optimizer(model)

        lr_scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode="min", factor=0.05, patience=2
        )
        loss_fn = nn.CrossEntropyLoss()

        model_path = f"working/{desease_name}"
        os.makedirs(model_path, exist_ok=True)

        with open(os.path.join(model_path, "label.txt"), "w", encoding="utf8") as file:
            file.write("\n".join(labels))

        num_epochs = 30

        best_val_acc, best_val_loss = 0.0, 100.0

        train_loss_epoch, val_loss_epoch = [], []
        train_acc_epoch, val_acc_epoch = [], []
        epoch_start = 0

        model = model.to(device)

        if False:
            dict_file = os.path.join(model_path, f"{model_name}.pt")
            pkl_file = os.path.join(model_path, f"v{model_name}.pickle")

            epoch_start, labels, model, optimizer = load_dict(
                model, optimizer, dict_file
            )
            train_epoch, valid_epoch = load_records(pkl_file)
            train_loss_epoch, train_acc_epoch = train_epoch["loss"], train_epoch["acc"]
            val_loss_epoch, val_acc_epoch = valid_epoch["loss"], valid_epoch["acc"]

        for e in range(epoch_start + 1, num_epochs + epoch_start + 1):
            train_acc, train_loss = 0.0, 0.0
            val_acc, val_loss = 0.0, 0.0
            model.train()
            for batch_id, batch in enumerate(tqdm.tqdm(train_loader)):
                optimizer.zero_grad()

                img = batch[0].to(device)
                label = batch[1].to(device)  # .squeeze(1) .float()

                out = model(img).squeeze(1)
                loss = loss_fn(out, label)

                train_loss += loss.item()
                loss.backward()

                optimizer.step()

                train_acc += calc_accuracy(out, label)

            tot_train_acc = train_acc / (batch_id + 1)
            mean_train_loss = train_loss / (batch_id + 1)
            train_loss_epoch.append(mean_train_loss)
            train_acc_epoch.append(tot_train_acc)
            print(
                "epoch {} train acc {} loss {}".format(
                    e, tot_train_acc, mean_train_loss
                )
            )

            model.eval()
            for batch_id, batch in enumerate(tqdm.tqdm(valid_loader)):

                img = batch[0].to(device)

                label = batch[1].to(device)  # .squeeze(1)

                out = model(img).squeeze(1)
                loss = loss_fn(out, label)
                val_loss += loss.item()
                val_acc += calc_accuracy(out, label)

            tot_acc = val_acc / (batch_id + 1)
            mean_val_loss = val_loss / (batch_id + 1)
            val_loss_epoch.append(mean_val_loss)
            val_acc_epoch.append(tot_acc)

            print("epoch {} valid acc {} loss {}".format(e, tot_acc, mean_val_loss))

            if best_val_loss > mean_val_loss:
                print(
                    "epoch {} train acc {} validation acc {}".format(
                        e, tot_train_acc, tot_acc
                    )
                )
                best_val_loss = mean_val_loss
                save_checkpoint(
                    e,
                    labels,
                    model,
                    optimizer,
                    train_loss_epoch,
                    val_loss_epoch,
                    train_acc_epoch,
                    val_acc_epoch,
                    model_path,
                    base_model_name,
                )

        loss_epoch_curve(
            model_path,
            base_model_name,
            train_loss_epoch,
            val_loss_epoch,
            train_acc_epoch,
            val_acc_epoch,
        )
