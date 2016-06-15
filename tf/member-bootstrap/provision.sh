
#!/usr/bin/env bash
sysctl -p /etc/sysctl.conf

export WEAVE_PASSWORD=$(cat /etc/terraform/weave_encryption)

if ! /usr/bin/docker -v 2> /dev/null | grep -q "^Docker\ version\ 1\.10" ; then
  echo "Installing current version of Docker Engine 1.10"
  curl --silent --location  https://get.docker.com/builds/Linux/x86_64/docker-1.10.3  --output /usr/bin/docker
  chmod +x /usr/bin/docker
fi

systemd-run --unit=docker.service /usr/bin/docker daemon

/usr/bin/docker version

if ! [ -x /usr/bin/weave ] ; then
  echo "Installing current version of Weave Net"
  curl --silent --location http://git.io/weave --output /usr/bin/weave
  chmod +x /usr/bin/weave
  /usr/bin/weave setup
fi

/usr/bin/weave version

/usr/bin/weave launch-router --init-peer-count 7

/usr/bin/weave launch-proxy --rewrite-inspect

for i in member_ips; do
  /usr/bin/weave connect $(cat /etc/terraform/$i)
done

/usr/bin/weave expose -h $(hostname).weave.local


# TODO enable once scope is secured
# if ! [ -x /usr/bin/scope ] ; then
#   echo "Installing current version of Weave Scope"
#   curl --silent --location http://git.io/scope --output /usr/bin/scope
#   chmod +x /usr/bin/scope
# fi

# /usr/bin/scope version

# /usr/bin/scope launch --probe.kubernetes="true" --probe.kubernetes.api="http://kube-apiserver.weave.local:8080"

eval $(/usr/bin/weave env)

save_last_run_log_and_cleanup() {
  if [[ $(docker inspect --format='{{.State.Status}}' $1) = 'exited' ]]
  then
    docker logs $1 > /var/log/$1_last_run 2>&1
    docker rm $1
  fi
}

case "$(hostname)" in
  kube-etcd-1)
    save_last_run_log_and_cleanup etcd1
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="etcd1" \
        weaveworks/kubernetes-anywhere:etcd-v1.2
    ;;
  kube-etcd-2)
    save_last_run_log_and_cleanup etcd2
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="etcd2" \
        weaveworks/kubernetes-anywhere:etcd-v1.2
    ;;
  kube-etcd-3)
    save_last_run_log_and_cleanup etcd3-v1.2
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="etcd3" \
        weaveworks/kubernetes-anywhere:etcd-v1.2
    ;;
  kube-master-1)
    save_last_run_log_and_cleanup kube-apiserver
    save_last_run_log_and_cleanup kube-controller-manager
    save_last_run_log_and_cleanup kube-scheduler

    docker run --name=kube-apiserver-pki bryanl/k8s-anywhere:apiserver-pki
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="kube-apiserver" \
      --volumes-from=kube-apiserver-pki \
        weaveworks/kubernetes-anywhere:apiserver-v1.2
    docker run --name=kube-controller-manager-pki bryanl/k8s-anywhere:controller-manager-pki
    docker run -d \
      --name=kube-controller-manager \
      --volumes-from=kube-controller-manager-pki \
        weaveworks/kubernetes-anywhere:controller-manager
    docker run --name=kube-scheduler-pki bryanl/k8s-anywhere:scheduler-pki
    docker run -d \
      --name=kube-scheduler \
      --volumes-from=kube-scheduler-pki \
        weaveworks/kubernetes-anywhere:scheduler

    docker run --name=kube-toolbox-pki bryanl/k8s-anywhere:toolbox-pki
    ;;
  ## kube-[5..N] are the cluster nodes
  kube-node-*)
    save_last_run_log_and_cleanup kubelet
    save_last_run_log_and_cleanup kube-proxy

    docker run -v /:/rootfs \
      -v /var/run/docker.sock:/docker.sock \
        weaveworks/kubernetes-anywhere:toolbox setup-kubelet-volumes
    docker run --name=kubelet-pki bryanl/k8s-anywhere:kubelet-pki
    docker run -d \
      --name=kubelet \
      --privileged=true \
      --net=host \
      --pid=host \
      --volumes-from=kubelet-volumes \
      --volumes-from=kubelet-pki \
         weaveworks/kubernetes-anywhere:kubelet

    docker run --name=kube-proxy-pki bryanl/k8s-anywhere:proxy-pki
    docker run -d \
      --name=kube-proxy \
      --privileged=true \
      --net=host \
      --pid=host \
      --volumes-from=kube-proxy-pki \
         weaveworks/kubernetes-anywhere:proxy

    docker run --name=kube-toolbox-pki bryanl/k8s-anywhere:toolbox-pki
    ;;
esac