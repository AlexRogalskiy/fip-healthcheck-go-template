# Deployment with Kustomization

In this file, there is the `kustomization` file which can be deployed using the
following command:

```sh
$ cp env_template .env
# Add the corresponding values in the .env file (explained below)
$ kustomize build . | kubectl apply -f -
# Output will show the resources being created
```

The contents of the `kustomization` file are as follows:

<!-- embedme kustomization.yaml -->

```yaml
# Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
#
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - role-binding.yaml
  - cronjob.yaml
configMapGenerator:
  - name: tbd-envs
    envs:
      - env_template

```

Like one can see, the three important resources created are the RBAC
policy *(through [`role-binding.yaml`](role-binding.yaml))*,
the cronjob doing the health check *(through [`cronjob.yaml`](cronjob.yaml) file)*
and the configmap created using the `configMapGenerator`.
Let us look into each to understand the configuration.

Before getting into each part, it is worth noting that the namespace in which
the resources are created is very important. We can specify a namespace in which
all the resources are created by kustomize in the `Kustomization` file. If the
namespace does not exist we will have to add a `yaml` to create the namespace in
the resources sections. If namespace is not explicitly defined, it will be `default`.

## RBAC setup

In the file [role-binding.yaml](./role-binding.yaml), three different resources are
created. First one is a Role called `example-check` has access to getting,
listing and watching - services, endpoints and pods. This role is bound to a
namespace and will be bound to the one in which it is created in. Then a
role-binding is creating that binds this role to a service account called
`example-check`. Consequenctly this service account is also
created under the same namespace. We will create our job with this service
account letting it access the services and endpoints under that particular
namespace.

A `ClusterRoleBinding` can be used as well, but it would give the service account
access to resources in the whole cluster. Be mindful of this choice.

## CronJob

In the file [cronjob](./example-check-cronjob)
we create a CronJob with the image of our tool. If you look under the containers
section you will notice that the environmental variables are injected from a
configMap created from the later section by kustomize. This environmental
variables are very important since they are used by our tool to decide which
service is to be monitored in which namespace and the number of endpoints
expected.

The entrypoint of the image used is /example-check which is
the binary build from the cmd/. This binary, as explained in the CLI usage guide,
expects flags, env vars, or configuration files. We use environment variables
while creating a job since it is the cleanest way *(open to a heated discussion)*
to inject data into a pod.

The environment variables necessary for the pod to execute are:

```yaml
TBD_SERVICE
TBD_NAMESPACE
TBD_MIN_EP
```

Refer the [CLI usage guide for detailed review of
this](../../cmd/example-check/README.md).

This environment variable data is expected inside the configMap. This configMap
can be injected like this in the job file:

``` yaml
            envFrom:
              - configMapRef:
                  name: tbd-envs
```

## ConfigMap

The configMap is created using `configMapGenerator` of kustomize. In the CronJob
file, we can see that a configMap of name tbd-envs is expected to hold the
aforementioned environmental variables. To create the configMap the following
kustomize section is used:

``` yaml
configMapGenerator:
- name: tbd-envs
  envs:
    - env_template
```

Here a tbd-envs configMap Kubernetes resource is created from an environment
file called `env_template`. The file has two keys defined with default values.

<!-- embedme env_template -->

```sh
TBD_SERVICE=
TBD_NAMESPACE=
TBD_MIN_EP=

```
