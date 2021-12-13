## Building the images

The Docker images in this container are build and pushed to DockerHub automatically by GitHub Actions. If you are testing these images or otherwise developing them locally, the commands below are equivalent to the commands run in the Actions to build the images.

### Docker commands

```bash
# Base image
docker build -t uclatall/base:latest -f dockerfiles/base.Dockerfile .

# DeepNote image
docker build -t uclatall/deepnote:latest -f dockerfiles/deepnote.Dockerfile .

# Binder image
docker build -t uclatall/binder:latest -f dockerfiles/binder.Dockerfile .
```
