## Building the images

The Docker images in this container are build and pushed to DockerHub automatically by GitHub Actions. If you are testing these images or otherwise developing them locally, the commands below are equivalent to the commands run in the Actions to build the images.

### Docker commands

```shell
docker build . \
  -f r-notebook.Dockerfile \
  -t uclatall/r-notebook:latest

docker build . \
  -f deepnote.Dockerfile \
  -t uclatall/deepnote:latest
```
