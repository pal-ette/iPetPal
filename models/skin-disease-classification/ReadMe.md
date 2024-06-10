# 피부질환 모델 분류 학습

### 데이터

- 224 x 224 images
- 380 x 380 images
- Image Augmentation `상하반전 좌우반전 90도, 180도, 270도 회전`
- 질환 부위 crop

### 분류

- 무증상 / 유증상 구분 이진분류
- 증상 6 클래스 구분
- 정확도 높은 증상 3클래스 + 무증상 구분
- 전체 7 클래스 구분

### 모델

- EfficientNet (b0 - b3)
- EfficientViT (b3)
- ViT
- Resnet
- Inception V4
- Inception Resnet V2