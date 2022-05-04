# UCLATALL Docker Images

This repository tracks and builds the Docker images used in different UCLATALL and CourseKata environments. There are three main images:
- `r-notebook`: A base image with R, Python, and Jupyter installed, as well as all of the R packages used frequently by our team and contributors. See [**R Notebook Image**](#r-notebook-image) below for details.
- `deepnote`: Currently this image is a clone of `r-notebook`, but this may change if we are testing new things in [Deepnote](https://deepnote.com). See [**Deepnote Image**](#deepnote-image) for details on how to use the image.

**Be extremely careful making any changes to this repository.** Changes commited to the Dockerfile on `main` will automatically be built, tagged, and published on [Docker Hub](https://hub.docker.com/repository/docker/uclatall). From there the images are used in numerous locations like the backend for CKCode, various Deepnote projects, and many other notebooks, including those of people outside of our organization. At minimum we need to be sure that the container is valid and works in the relevant environment before publishing. If you are unsure how to do this, don't make any changes and instead ask [@adamblake](https://github.com/adamblake).

## R Notebook Image

This image includes most of the set up for the other images. In particular, it sets up the virtual environment, installs Python, R, and Jupyter, and all the R packages used by our team. Below is an abbreviated list of the R packages that are currently installed. If you would like a package added, create an Issue or ask [@adamblake](https://github.com/adamblake) to make sure it is installed.

- [coursekata](https://github.com/UCLATALL/coursekata-r) (includes all course packages)
- tidyverse
- car
- ClustOfVar
- cluster
- dagitty
- jtools
- gganimate
- ggdag
- ggformula
- ggpubr
- lme4
- mapproj
- mosaic
- psych
- OCSData
- simstudy
- tidymodels

## Deepnote Image

The Deepnote image builds on the base image to provide functionality for notebooks at [deepnote.com](https://deepnote.com). To use this image with a Deepnote project, follow these steps:

1. Create a new project or open an existing project
2. Using the left menu, click the Environment tab (the icon is a computer chip)
3. Click "Set up a new Docker image"
4. In the popup form there will be two input boxes. In the first one, "Docker Image", type `uclatall/deepnote:latest`
5. Click "Add environment & apply" and wait for the changes to take effect and the machine to restart

# Using these images with Binder

The `r-notebook` image will run in BinderHub environments like [MyBinder.org](https://mybinder.org). To use this image in a Binder, you will need to create a separate GitHub repository with a Dockerfile that references this image. Here are the steps:

1. Create a new, public GitHub repository
2. In that repository create a file called `Dockerfile`
3. In the `Dockerfile` paste the following:

```Dockerfile
FROM uclatall/binder:latest

# Fix plot sizes
RUN echo 'options(repr.plot.width = 6, repr.plot.height = 4)' > ~/.Rprofile
```

4. Open your repository via a site like [MyBinder.org](https://mybinder.org)
