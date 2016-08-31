#!/bin/bash

NAMESPACE=mnubo
REPOSITORY=elasticsearch
VERSION=2.3.5

docker build -t $NAMESPACE/$REPOSITORY:$VERSION .
