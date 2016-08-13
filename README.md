# MNIST database of handwritten digits in MATLAB format

This repository provides a simple conversion function of the original MNIST dataset into MATLAB `.mat` format for easy usage. Be sure to also pull the submodules containing the [original](https://github.com/sunsided/mnist) MNIST dataset.

In order to convert the data, execute

```matlab
convertMNIST
```

once in this directory, which will create `mnist.mat`. After that, you can use

```matlab
load('mnist.mat')
```

which will load two variables into your workspace:

- `training`, which contains the training set and
- `test`, which contains the test set.

Both variables are represented as structures of the following fields:

- `count`: The number `N` of images
- `width`: The width `W` of each image
- `height`: The height `H` of each image
- `images`: A `H` by `W` by `N` array of all images
- `labels`: An array of `N` values describing the image label

The `images` are encoded as doubles with a range of `0`..`1`, where `0` is background and `1` is foreground. The original MNIST dataset interprets these as `0` for white and `1` for black.

The `labels` field is encoded as categorical double values in the range of `0` through `9` inclusive.