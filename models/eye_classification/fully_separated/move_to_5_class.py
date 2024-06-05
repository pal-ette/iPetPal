import glob
import os
import shutil
import tqdm
from shared import print_file_count

if __name__ == "__main__":
    base_dir = "D:\\CVProject\\개_안구_400x400_train_test"
    target_dir = "D:\\CVProject\\개_안구_400x400_train_test_5class"

    labels = ["궤양성각막질환", "백내장", "안검종양", "핵경화"]

    for image_path in (pbar := tqdm.tqdm(glob.glob(f"{base_dir}\\*\\*\\*"))):
        image_depth, image_name = os.path.split(image_path)
        label_depth, label = os.path.split(image_depth)
        _, desease = os.path.split(label_depth)
        pbar.set_description(f"{desease}({label})")

        desease_name, train_group = desease.split("_")
        if desease_name not in labels:
            continue
        target_image_path = os.path.join(
            target_dir,
            train_group,
            f"{desease_name}" if label != "무" else "정상",
            image_name,
        )
        os.makedirs(os.path.dirname(target_image_path), exist_ok=True)
        shutil.copyfile(image_path, target_image_path)
    print_file_count(target_dir, depth=2)
