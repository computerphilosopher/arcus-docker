include Docker.env
export $(shell sed 's/=.*//' Docker.env)

ZK_CLI_IMAGE=${ZK_CLI_IMAGE_REPO}:${ARCUS_ZOOKEEPER_IMAGE_TAG}

build:
	@ sed 's|\$${ARCUS_ZOOKEEPER_VERSION}|${ARCUS_ZOOKEEPER_VERSION}|g' Dockerfile.template > Dockerfile
	@ docker build -t ${ZK_CLI_IMAGE} . --network=host

push:
	@ docker push ${ZK_CLI_IMAGE}
