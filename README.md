# Anime Segmentation in Docker

- <https://github.com/SkyTNT/anime-segmentation>

## Environments

- Ubuntu 20.04 or later
- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) 23.0 or later
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## Usage
### 1. Build Docker image

```shell
docker build . -t aoirint/anime_segmentation
```

### 2. Download Model

- <https://huggingface.co/skytnt/anime-seg/>

```shell
#  Create a model directory (UID:GID = 1000:1000)
mkdir model

wget 'https://huggingface.co/skytnt/anime-seg/resolve/a0a563c41338cbe0d23dfb4bfc3e243c518e5768/isnetis.ckpt'
echo '2c8f6b9a77386c54dcdbf55b6c917108c4bdf4328abca9152c7bce5727b74d18  isnetis.ckpt' | sha256sum -c -
```

### 3. Run Inference

```shell
# Create a input / output directory (UID:GID = 1000:1000)
mkdir data
mkdir out

docker run --rm --gpus all -v "./model:/model" -v "./data:/data" -v "./out:/out" aoirint/anime_segmentation --net isnet_is --ckpt "/model/isnetis.ckpt" --data "/data" --out "/out" --img-size 1024 --only-matted
```
