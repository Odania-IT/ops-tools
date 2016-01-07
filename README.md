# ops-tools

Helper scripts for managing the servers.

## Configuration

The configuration file ops-config.yml is searched either under /etc or the directory of the ops installation and all paths above.

You can use the command
```
ops config init
```
to create or update a configuration with all options.

Example:
```
docker:
  email: your-mail@example.com
  user: my-user
  password: my-password
  url: https://my-docker-registry
```

## Docker

### build

This command builds tags and pushes an image to a docker registry.

Example:
```
bundle exec ops docker build ~/workspace/docker/docker-jenkins-odania docker-jenkins-odania
```

This will do the following steps:
1. Login to the registry
2. Get the highest version number from the registry
3. Detect the base image (in this case odaniait/docker-jenkins:latest) and pull it. To make sure it is up to date.
4. Build the docker image in the folder
5. Tag the image with the version vBUILD_NUMBER and latest
6. Push the image

You can additionally add the version number as a last parameter, e.g.
```
bundle exec ops docker build ~/workspace/docker/docker-jenkins-odania docker-jenkins-odania 10
```
This will build and push to v10 and latest.

#### Version numbers

Version numbers are expected to be in tags like v1 (vNUMBER in general).

### base_image_check

This command checks all Dockerfiles under <folder> for new base images.

The folder name has to be the name of the image. The image is looked up in the registry from the config.

Example:
```
bundle exec ops docker base_image_check ~/workspace/docker
```

* Important: For the detection to work you need to have the FROM in the first line followed by a line with MAINTAINER! *
