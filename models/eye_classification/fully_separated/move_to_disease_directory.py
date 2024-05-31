import glob
import os
import shutil
import tqdm
from shared import print_file_count

if __name__ == "__main__":
    base_dir = "D:\\CVProject\\개_안구_resized_train_test"
    target_dir = "D:\\CVProject\\개_안구_resized_train_test_desease_only"

    for image_path in (pbar := tqdm.tqdm(glob.glob(f"{base_dir}\\*\\*\\*"))):
        image_depth, image_name = os.path.split(image_path)
        label_depth, label = os.path.split(image_depth)
        _, desease = os.path.split(label_depth)
        pbar.set_description(f"{desease}({label})")
        if label == "무":
            continue
        desease_name, train_group = desease.split("_")
        target_image_path = os.path.join(
            target_dir,
            train_group,
            f"{desease_name}_{label}",
            image_name,
        )
        os.makedirs(os.path.dirname(target_image_path), exist_ok=True)
        shutil.copyfile(image_path, target_image_path)
    print_file_count(target_dir, depth=2)

"""
test (14)
- 결막염_유 (100)
- 궤양성각막질환_상 (100)  
- 궤양성각막질환_하 (100)  
- 백내장_비성숙 (100)      
- 백내장_성숙 (100)        
- 백내장_초기 (100)        
- 비궤양성각막질환_상 (100)
- 비궤양성각막질환_하 (100)
- 색소침착성각막염_유 (100)
- 안검내반증_유 (100)      
- 안검염_유 (100)
- 안검종양_유 (100)        
- 유루증_유 (100)
- 핵경화_유 (100)
train (14)
- 결막염_유 (10701)       
- 궤양성각막질환_상 (7627)
- 궤양성각막질환_하 (7641)
- 백내장_비성숙 (7658)      
- 백내장_성숙 (7627)        
- 백내장_초기 (7638)        
- 비궤양성각막질환_상 (5299)
- 비궤양성각막질환_하 (5304)
- 색소침착성각막염_유 (7822)
- 안검내반증_유 (10699)
- 안검염_유 (7638)
- 안검종양_유 (5286)
- 유루증_유 (10697)
- 핵경화_유 (10698)
"""
