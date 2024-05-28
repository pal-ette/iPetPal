import os, shutil
from PIL import Image

ori = 'D:/skin_data/region_dataset/region_multi'
dest = 'D:/skin_data/region_dataset/region_multi_augmented'
target = ['A1', 'A4', 'A5', 'A6'] # .startswith(tuple(target))

# A A5 / H A4 A5 A6

# for disease in target:
#     file_path = os.path.join(dest, disease[0], disease[1])
#     print(disease, len(os.listdir(file_path)))
#     for file in os.listdir(file_path):
#         if file.startswith('rotated'):
#             img = Image.open(os.path.join(file_path, file))
#             img.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(file_path, f'hflip_{file}'))
#             img.transpose(Image.FLIP_TOP_BOTTOM).save(os.path.join(file_path, f'vflip_{file}'))
#     print(disease, len(os.listdir(file_path)))

for region in ['A', 'H']: # os.listdir(ori):
    if not os.path.exists(os.path.join(dest, region)):
        os.makedirs(os.path.join(dest, region))
    for disease in os.listdir(os.path.join(ori, region)):
        if disease.startswith(tuple(target)):
            print(region, disease, len(os.listdir(os.path.join(ori, region, disease))))
            cnt = 0
            final_path = os.path.join(dest, region, disease)
            if not os.path.exists(final_path):
                os.makedirs(final_path)
            for file in os.listdir(os.path.join(ori, region, disease)):
                img = Image.open(os.path.join(ori, region, disease, file))
                img.rotate(90).save(os.path.join(final_path, f'rotated90_{file}'))
                img.rotate(180).save(os.path.join(final_path, f'rotated180_{file}'))
                img.rotate(270).save(os.path.join(final_path, f'rotated270_{file}'))
                img.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(final_path, f'hflip_{file}'))
                img.transpose(Image.FLIP_TOP_BOTTOM).save(os.path.join(final_path, f'vflip_{file}'))
                cnt += 1
                if cnt % 500==0:
                    print(f'{cnt} files augmented')
            print(region, disease, "done")