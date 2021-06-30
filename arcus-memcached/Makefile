include Docker.env
export $(shell sed 's/=.*//' Docker.env)

ARCUS_MEMCACHED_IMAGE=${ARCUS_MEMCACHED_IMAGE_REPO}:${ARCUS_MEMCACHED_IMAGE_TAG}

ZK_VERSION=$(shell ./zk_env.sh ${ARCUS_MEMCACHED_VERSION} ZK_VERSION)
ZK_CLIENT_PATH=$(shell ./zk_env.sh ${ARCUS_MEMCACHED_VERSION} ZK_CLIENT_PATH)

build:
	@ sed -e 's|\$${ARCUS_MEMCACHED_VERSION}|${ARCUS_MEMCACHED_VERSION}|g' \
		-e 's|\$${ZK_VERSION}|${ZK_VERSION}|g' \
		-e 's|\$${ZK_CLIENT_PATH}|${ZK_CLIENT_PATH}|g' \
		Dockerfile.template > Dockerfile
	@ docker build -t ${ARCUS_MEMCACHED_IMAGE} . --network=host

push:
	@ docker push ${ARCUS_MEMCACHED_IMAGE}
