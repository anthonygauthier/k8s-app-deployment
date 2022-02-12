# k8s-app-deployment
# Overview
This app uses the following tech stack:

* Node.JS
* k6
* GitHub Actions
* helm
* Kubernetes (in the case of the workflows: AWS EKS)
* Terraform

The app is a small REST app with a single endpoint developed in Node using express, it is located in `app/`. It is containerized using Docker and pushed to GitHub Container Registry.

The infrastructure on which the app is deployed (by using Helm) is built by a Terraform module contained in `terraform/`

All of the builds, test, and deployments are automated through GitHub Action Workflows located in `.github/workflows`.

Once the infra is deployed. The app is then deployed with Helm using the Chart located in `helm/`. Upon completion, a performance/functional test is launched using k6 (tests located in `test/`) verifying that the endpoint is responding through the loadbalancer and that it has acceptable response times. If it isn't, the app is removed from the cluster.**

The cluster can be destroyed by a GitHub Action that is executed manually.

** In a real world app setting, the container image would be using semantic-versioning and only the version being deployed would be deleted from the cluster.

# How To
## Run app in the cloud
__Prerequisites__:
* `helm`
* an EKS cluster
* a configured .kubeconfig
* This repo cloned onto your workstation

### Deploy
To deploy the app to your EKS cluster, you simply execute this helm command:

```bash
# pwd == repo root
helm install -f helm/values.yaml --set image.branchName=main k8s-app ./helm
```

### Destroy
To destroy the app execute the following helm command:

```bash
# pwd == repo root
helm uninstall k8s-app
```

---

## Run app locally
__Prerequisites__:
* node
* npm

### Run the app
`npm run start`

### Run the tests
`npm run test`
