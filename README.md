# Getting up and running with Argo workflows locally


## Local kubernetes

### Kind

You can use [kind](https://kind.sigs.k8s.io/), or Minikube. In this setup we use Kind (Kubernetes in Docker). The requirement is to have Docker installed.

To install Kind. See below.

```bash
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/bin/
```

To create a cluster it is simply

```bash
    # creates the cluster
    kind create cluster --name test-cluster

    # sets the kube context in ~/.kube/config
    kubectl cluster-info --context kind-test-cluster
```

### Kubectl

Kubectl is the tool to interact with the Kubernetes cluster.

```bash
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl

    # check version on both the client and the cluster
    kubectl version --client
```

It is also pretty useful to set an alias.

```bash
    alias k=kubectl
```

Tab completion is must, example set-up [link](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/)


## kubectx and kubens

For a multi-cluster environment and multi-namspaces, kubectx and kubns are useful for switching clusters and namespaces, respectively.

To install

```bash
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    sudo chmod +x /opt/kubectx/kubens
    sudo chmod +x /opt/kubectx/kubectx

    # tab completion is very useful for kubens and kubectx, setup before is for oh-my-zsh
    mkdir -p ~/.oh-my-zsh/completions
    chmod -R 755 ~/.oh-my-zsh/completions
    ln -s /opt/kubectx/completion/kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh
    ln -s /opt/kubectx/completion/kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh
```


## Argo workflows

Argo is an cloud-native workflow orchastrator. You install Argo custom resource defintion on the kubernetes cluster, which then give you the capabilities to submit jobs/workflow using YAML. Note if you prefer not to write YAML, you can use the Kubeflow pipelines SDK, which allows you to write workflows in python. The next step is kf pipelines can compile the pipeline definition to YAML, which can then be used directly with Argo.

To install argo-crd and cli, see the example installation script [argo_install.sh](./examples/argo/argo_install.sh)

To get this to work properly you need to create a Service Account, RBAC role and role binding to the created service account.

```bash
    k apply -f -n the-namespace-you-want ./examples/argo/rbac.yaml
```

In all workflow add the `serviceAccountName: workflow` under the workflow spec definition.

### Argo Workflows example

Example multi-step workflow.

```bash

    argo submit -n argo --watch examples/argo/whale-workflow.yaml

    # to run a multi-step workflow from a file
    argo submit -n argo --watch examples/argo/muti-step-workflow.yaml --entrypoint whalesay -p message=flowify

    # to see the logs
    argo logs @latest

    # useful cli commands
    # argo list
    # argo delete
    # argo lint
    # argo resubmit
    # argo help
```

Using the argo-ui

```bash
    kubectl -n argo port-forward deployment/argo-server 2746:2746
```

At localhost:2746, you can also use the argo-ui to create and monitor workflows.


### Further testing

From this point onwards, you can test out the different argo workflow features from the examples [link](https://argoproj.github.io/argo-workflows/examples/).
```
    kind load docker-image my-custom-image:v0 --name flowify-cluster
```

Try out:

* [workflow input parameters](https://argoproj.github.io/argo-workflows/examples/#parameters)
* [steps](https://argoproj.github.io/argo-workflows/examples/#steps) vs [dags](https://argoproj.github.io/argo-workflows/examples/#dag)
* [loops](https://argoproj.github.io/argo-workflows/examples/#loops)
* [Artifacts](https://argoproj.github.io/argo-workflows/examples/#artifacts)
* [worklfow templates](https://argoproj.github.io/argo-workflows/workflow-templates/)
* [script & results](https://argoproj.github.io/argo-workflows/examples/#scripts-results)
* [conditionals](https://argoproj.github.io/argo-workflows/examples/#conditionals)
* [recursion and dynamic workflows](https://argoproj.github.io/argo-workflows/examples/#recursion)
* [exit handlers](https://argoproj.github.io/argo-workflows/examples/#exit-handlers)
* [share volume between workflows](https://argoproj.github.io/argo-workflows/examples/#volumes)

Create your own workflows using your own customize docker images. Since we are using Kind as our "cluster", remember to make custom images availible in the Kind cluster use the following command.

-> **Tip** do not use ":latest" tag, as that does not work as expected when imported to kind, rather use some other label.



### Argo workflow API

In the UI on the right menu, there is an API-docs button. This shows the Swagger definition. Look at the different endpoints that are availible. Also you can try to submit and interact with the API using curl, for [example](https://argoproj.github.io/argo-workflows/rest-examples/)

### IDE set-up

Writing workflows using the YAML can be error prone, you can add json schema for validation and autocompletion, which really improves productivity. [Link](https://argoproj.github.io/argo-workflows/ide-setup/) how to set this up for VScode, and IntelliJ IDEA.