# Workshop notes

## Setup

### Boot kubernetes

### Configure kubernetes

#### Setup Sentry secrets

Add sentry key using kubelet

```sh
 kubectl create secret generic sentry-secret-key --from-rom=./sentry_secret_key.txt
```