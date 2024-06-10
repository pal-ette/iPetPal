import os
import torch
import torch.nn as nn
from torchvision import datasets, transforms
import tqdm
from shared import (
    load_dict,
    get_model,
    get_optimizer,
    loss_epoch_curve,
    load_records,
    calc_accuracy,
    save_checkpoint,
)
import model_preset as mp

if __name__ == "__main__":
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    model_preset = mp.Levit128sSkin4Class()

    batch_size = model_preset.batch_size()
    base_path = model_preset.dataset_path()
    base_model_name = model_preset.model_name()
    data_transform = model_preset.data_transform()
    train_transform = model_preset.train_transform()
    valid_transform = model_preset.valid_transform()
    model_filename = model_preset.get_filename()

    dataset = datasets.ImageFolder(
        os.path.join(base_path, "train"),
        transform=data_transform,
    )

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

    model_path = f"working/classification_desease/"
    os.makedirs(model_path, exist_ok=True)

    with open(os.path.join(model_path, "label.txt"), "w", encoding="utf8") as file:
        file.write("\n".join(labels))

    num_epochs = 1000

    best_val_acc, best_val_loss = 0.0, 100.0

    train_loss_epoch, val_loss_epoch = [], []
    train_acc_epoch, val_acc_epoch = [], []
    epoch_start = 0

    model = model.to(device)

    if False:
        dict_file = os.path.join(model_path, f"{model_filename}.pt")
        pkl_file = os.path.join(model_path, f"{model_filename}.pickle")

        epoch_start, labels, model, optimizer = load_dict(model, optimizer, dict_file)
        train_epoch, valid_epoch = load_records(pkl_file)
        train_loss_epoch, train_acc_epoch = train_epoch["loss"], train_epoch["acc"]
        val_loss_epoch, val_acc_epoch = valid_epoch["loss"], valid_epoch["acc"]

    for e in range(epoch_start + 1, num_epochs + epoch_start + 1):
        train_acc, train_loss = 0.0, 0.0
        val_acc, val_loss = 0.0, 0.0
        model.train()
        for batch_id, batch in enumerate(pbar := tqdm.tqdm(train_loader)):
            pbar.set_description(f"{e} epoch (train)")
            optimizer.zero_grad()

            img = batch[0].to(device)
            label = batch[1].to(device)  # .squeeze(1) .float()

            img = train_transform(img)
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
        print("epoch {} train acc {} loss {}".format(e, tot_train_acc, mean_train_loss))

        model.eval()
        for batch_id, batch in enumerate(pbar := tqdm.tqdm(valid_loader)):
            pbar.set_description(f"{e} epoch (valid)")

            img = batch[0].to(device)

            label = batch[1].to(device)  # .squeeze(1)

            img = valid_transform(img)
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
                model_filename,
            )

        loss_epoch_curve(
            model_path,
            model_filename,
            train_loss_epoch,
            val_loss_epoch,
            train_acc_epoch,
            val_acc_epoch,
        )
