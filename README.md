# docker-images
Mnubo open source Docker images Dockerfiles

We try to build our images with as few layers as possible to reduce size, pull, and startup times. However, we usually don't go as far as using minimal linux distros like alpine, in order for our production containers to be easily debuggable with vi, etc...

## mnubo/jre8

An image for running JVM based applications on the Oracle JRE 1.8 and Debian Jessie.

Example usage:

    docker run -v /path/to/some/application.jar:/app/application.jar mnubo/jre8 -jar /app/application.jar
