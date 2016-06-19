#!/usr/bin/env bash

set -e

scriptDir=$(dirname $0)

tmpdir=$(mktemp -d -t k8s)

resourceDir=${tmpdir}/resources
mkdir -p $resourceDir

cp ${scriptDir}/../*.yaml ${resourceDir}

cd $tmpdir
tar --disable-copyfile -C ${tmpdir} -czf ${tmpdir}/resources.tar.gz resources

mc cp ${tmpdir}/resources.tar.gz mys3/velocity2016

rm -rf ${tmpdir}