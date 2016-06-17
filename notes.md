# Workshop notes

## Setup

### Boot kubernetes

### Configure kubernetes

#### Setup Sentry secrets

Add sentry key using kubelet

```sh
 kubectl create secret generic sentry-secret-key --from-rom=./sentry_secret_key.txt
```

### Deploy resources

Create all resources

* `kubectl create -f http://s3.pifft.com/velocity2016/elasticsearch.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/logstash.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/traefik.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/filebeat.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/kibana.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/prometheus.yaml`
* `kubectl create -f http://s3.pifft.com/velocity2016/sentry.yaml`

Configure sentry

```sh
$ kubectl exec -it -c sentry sentry-pod bash
$ sentry upgrade
$ exit
```

At the end of the process, it will ask for an email and a password.

* With your web browser, visit [http://sentry.k8sdev](http://sentry.k8sdev), and log in with the email and
password you previously created.
* Create a project named api.
* Copy the sentry DSN for your new project. It will look something like, http://6f00c6fce5dc47ecaba78e223c15b369:a6cc1634c867439d83d5aff3ccbe42c8@sentry.k8sdev/2


