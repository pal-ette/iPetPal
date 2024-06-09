from abc import *

from torchvision.transforms import (
    ToTensor,
    Normalize,
    Compose,
    RandomHorizontalFlip,
    RandomVerticalFlip,
    RandomRotation,
    RandomCrop,
    RandomErasing,
    Resize,
    ColorJitter,
)


class model_preset(metaclass=ABCMeta):

    @abstractmethod
    def model_name(self):
        pass

    @abstractmethod
    def data_transform(self):
        pass

    @abstractmethod
    def train_transform(self):
        pass

    @abstractmethod
    def valid_transform(self):
        pass

    @abstractmethod
    def get_filename(self):
        pass

    @abstractmethod
    def dataset_path(self):
        pass

    @abstractmethod
    def batch_size(self):
        pass


class Resnet50(model_preset):

    def model_name(self):
        return "resnet50"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
            ]
        )

    def train_transform(self):
        return Compose([])

    def valid_transform(self):
        return Compose([])

    def get_filename(self):
        return "resnet50"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_resized_train_test_desease_only"

    def batch_size(self):
        return 32


class Efficientnet(model_preset):

    def model_name(self):
        return "efficientnet_b0"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
            ]
        )

    def train_transform(self):
        return Compose([])

    def valid_transform(self):
        return Compose([])

    def get_filename(self):
        return "efficientnet_b0"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_resized_train_test_desease_only"

    def batch_size(self):
        return 32


class Resnetv250_Imagenet(model_preset):

    def model_name(self):
        return "resnetv2_50"

    def data_transform(self):
        mean_ = (0.485, 0.456, 0.406)
        std_ = (0.229, 0.224, 0.225)
        return Compose(
            [
                ToTensor(),
                Normalize(mean_, std_),
            ]
        )

    def train_transform(self):
        return Compose([])

    def valid_transform(self):
        return Compose([])

    def get_filename(self):
        return "resnetv2_50_imagenet"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_resized_train_test_desease_only"

    def batch_size(self):
        return 32


class Resnetv250_random(model_preset):

    def model_name(self):
        return "resnetv2_50"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                Normalize(
                    mean=[0.3199, 0.2240, 0.1609],
                    std=[0.3020, 0.2183, 0.1741],
                ),
            ]
        )

    def train_transform(self):
        return Compose([])

    def valid_transform(self):
        return Compose([])

    def get_filename(self):
        return "Resnetv250_random"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_resized_train_test_desease_only"

    def batch_size(self):
        return 32


class Efficientnet_320crop(model_preset):

    def model_name(self):
        return "efficientnet_b0"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
                RandomCrop((320, 320)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                Normalize(
                    mean=[0.3199, 0.2240, 0.1609],
                    std=[0.3020, 0.2183, 0.1741],
                ),
            ]
        )

    def train_transform(self):
        return Compose([])

    def valid_transform(self):
        return Compose([])

    def get_filename(self):
        return "efficientnet_320crop"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_400x400_train_test_desease_only"

    def batch_size(self):
        return 24


class Efficientnet_224crop(model_preset):

    def model_name(self):
        return "efficientnet_b0"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
            ]
        )

    def train_transform(self):
        return Compose(
            [
                Resize((256, 256)),
                RandomCrop((224, 224)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                ColorJitter(
                    brightness=0.8,
                    contrast=0.8,
                ),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
                RandomErasing(),
            ]
        )

    def valid_transform(self):
        return Compose(
            [
                Resize((224, 224)),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
            ]
        )

    def get_filename(self):
        return "efficientnet_224crop"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_400x400_train_test_desease_only"

    def batch_size(self):
        return 32


class Efficientnet_final(model_preset):

    def model_name(self):
        return "efficientnet_b0"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
            ]
        )

    def train_transform(self):
        return Compose(
            [
                Resize((320, 320)),
                RandomCrop((224, 224)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                ColorJitter(
                    brightness=0.8,
                    contrast=0.8,
                ),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
                RandomErasing(),
            ]
        )

    def valid_transform(self):
        return Compose(
            [
                Resize((224, 224)),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
            ]
        )

    def get_filename(self):
        return "efficientnet_final"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_400x400_train_test_desease_only"

    def batch_size(self):
        return 32


class VisionTransformer(model_preset):

    def model_name(self):
        return "vit_base_patch16_224"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
            ]
        )

    def train_transform(self):
        return Compose(
            [
                Resize((320, 320)),
                RandomCrop((224, 224)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                ColorJitter(
                    brightness=0.8,
                    contrast=0.8,
                ),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
                RandomErasing(),
            ]
        )

    def valid_transform(self):
        return Compose(
            [
                Resize((224, 224)),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
            ]
        )

    def get_filename(self):
        return "vit"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_400x400_train_test_desease_only"

    def batch_size(self):
        return 24


class VisionTransformer5class(model_preset):

    def model_name(self):
        return "vit_base_patch16_224"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
            ]
        )

    def train_transform(self):
        return Compose(
            [
                Resize((320, 320)),
                RandomCrop((224, 224)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                ColorJitter(
                    brightness=0.8,
                    contrast=0.8,
                ),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
                RandomErasing(),
            ]
        )

    def valid_transform(self):
        return Compose(
            [
                Resize((224, 224)),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
            ]
        )

    def get_filename(self):
        return "vit_5class"

    def dataset_path(self):
        return "D:\\CVProject\\개_안구_400x400_train_test_5class"

    def batch_size(self):
        return 24


class VisionTransformerSkin4class(model_preset):

    def model_name(self):
        return "vit_base_patch16_224"

    def data_transform(self):
        return Compose(
            [
                ToTensor(),
            ]
        )

    def train_transform(self):
        return Compose(
            [
                Resize((320, 320)),
                RandomCrop((224, 224)),
                RandomRotation((-180, 180)),
                RandomHorizontalFlip(),
                RandomVerticalFlip(),
                ColorJitter(
                    brightness=0.8,
                    contrast=0.8,
                ),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
                RandomErasing(),
            ]
        )

    def valid_transform(self):
        return Compose(
            [
                Resize((224, 224)),
                Normalize(
                    mean=[0.5, 0.5, 0.5],
                    std=[0.5, 0.5, 0.5],
                ),
            ]
        )

    def get_filename(self):
        return "vit_skin_4class"

    def dataset_path(self):
        return "D:\\CVProject\\피부"

    def batch_size(self):
        return 24
