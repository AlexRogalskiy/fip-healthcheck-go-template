# example-check CLI usage

The tool expects TBD input information to function:

* first one
* second one
* next

These values can be provided in three different ways:

## As flags to the command

For eg, the following command can be used to check if TBD.

``` sh
$ example-check --flag-1 1 --flag-2 2
# output

INFO[0000] Info message with flag-1=1 and flag-2=2
```

`flag-3`(flag-3) is optional and will get default values `1` and `default` respectively.

## As environment variables

If no flags are provided, the tool looks for environment variables for getting
the information. To avoid possible confusion, the environment variables has the
prefix `TBD`. The usage can be as follows:

``` sh
$ export TBD_FLAG_1=1 # ENV var for flag-1, notice that `-` becomes `_`
$ export TBD_FLAG_2=2 # ENV var for flag-2, notice that `-` becomes `_`

$ example-check --KUBECONFIG ~/.kubeconfig

#output
INFO[0000] Info message with flag-1=1 and flag-2=2
```

`flag-3`(flag-3) is optional and will get default values `1` and `default` respectively.

## As configuration file

If the tool couldn't find the values in the above two cases, it looks for a
configuration file with the data. By default, it looks for the file
`$HOME/.example-check.yaml` if a flag `--config` with the right file
is not provided.

An example usage is:

``` sh
$ cat /home/username/.config
flag-1: 1
flag-2: 2
flag-3: 3

$ example-check --config /home/username/.config
INFO[0000] Info message with flag-1=1 and flag-2=2
```

## Monitoring a remote cluster

By default, the tool expects the Kubernetes cluster is present locally and
hence look for a kubeconfig at `~/.kube/config`. To override this and connect to a
remote cluster you could use one of the following:
- the `--KUBECONFIG` flag
- set an env var named `SEC_KUBECONFIG`
- provide the env var in the config file you are using by setting the `KUBECONFIG` key

An example usage is:

``` sh
$ export KUBECONFIG=/home/username/kubebin/kubeconfig
$ example-check --flag-1 1 --flag-2 2
INFO[0000] Info message with flag-1=1 and flag-2=2
```
