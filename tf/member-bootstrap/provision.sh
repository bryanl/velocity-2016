
#!/usr/bin/env bash
sysctl -p /etc/sysctl.conf

MYIP=$(ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

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
  mkdir -p /opt/cni/bin
  mkdir -p /etc/cni/net.d
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

NODE_IP=$(ifconfig weave | grep 'inet addr:' | cut -d: -f2 | cut -f1 | awk '{print $1}')

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
        bryanl/k8s-do:etcd-v1.2
    ;;
  kube-etcd-2)
    save_last_run_log_and_cleanup etcd2
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="etcd2" \
        bryanl/k8s-do:etcd-v1.2
    ;;
  kube-etcd-3)
    save_last_run_log_and_cleanup etcd3-v1.2
    docker run --detach \
      --env="ETCD_CLUSTER_SIZE=3" \
      --name="etcd3" \
        bryanl/k8s-do:etcd-v1.2
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
        bryanl/k8s-do:apiserver-v1.2
    docker run --name=kube-controller-manager-pki bryanl/k8s-anywhere:controller-manager-pki
    docker run -d \
      --name=kube-controller-manager \
      --volumes-from=kube-controller-manager-pki \
        bryanl/k8s-do:controller-manager
    docker run --name=kube-scheduler-pki bryanl/k8s-anywhere:scheduler-pki
    docker run -d \
      --name=kube-scheduler \
      --volumes-from=kube-scheduler-pki \
        bryanl/k8s-do:scheduler

    docker run --name=kube-toolbox-pki bryanl/k8s-anywhere:toolbox-pki
    ;;
  ## kube-[5..N] are the cluster nodes
  kube-node-*)
    save_last_run_log_and_cleanup kubelet
    save_last_run_log_and_cleanup kube-proxy

    docker run -v /:/rootfs \
      --env="USE_CNI=yes" \
      -v /var/run/docker.sock:/docker.sock \
        bryanl/k8s-do:toolbox setup-kubelet-volumes
    docker run --name=kubelet-pki bryanl/k8s-anywhere:kubelet-pki
    docker run -d \
      --env="USE_CNI=yes" \
      --env="NODE_IP=$NODE_IP" \
      --name=kubelet \
      --privileged=true \
      --net=host \
      --pid=host \
      --volumes-from=kubelet-volumes \
      --volumes-from=kubelet-pki \
         bryanl/k8s-do:kubelet

    docker run --name=kube-proxy-pki bryanl/k8s-anywhere:proxy-pki
    docker run -d \
      --env="USE_CNI=yes" \
      --name=kube-proxy \
      --privileged=true \
      --net=host \
      --pid=host \
      --volumes-from=kube-proxy-pki \
         bryanl/k8s-do:proxy

    docker run --name=kube-toolbox-pki bryanl/k8s-anywhere:toolbox-pki
    ;;
  kube-lb-*)
    curl --silent --location https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kubectl --output /usr/bin/kubectl
    chmod +x /usr/bin/kubectl
    systemctl daemon-reload
    systemctl start caddy
    ;;
  kube-frontend-*)
    curl --silent --location https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kubectl --output /usr/bin/kubectl
    chmod +x /usr/bin/kubectl
    systemctl daemon-reload
    systemctl start traefik
    ;;
esac