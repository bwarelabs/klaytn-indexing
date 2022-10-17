# GCP GKE

These instructions will walk you through spinning up a GKE cluster and a CloudSQL
database in GCP using Terraform. Afterwards, we will use helm and kubectl to 
deploy a Graph Node (+ other helper services) on top of them. 

### Prerequisites

* A GCP project: https://cloud.google.com/resource-manager/docs/creating-managing-projects
* Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/gcp-get-started
* GCloud CLI: https://cloud.google.com/sdk/docs/install
* Kubectl: https://kubernetes.io/docs/tasks/tools/
* Helm: https://helm.sh/docs/intro/install/
* A Klaytn API Endpoint

### Setup

* Configure your GCloud CLI (and implicitly Terraform): 
https://cloud.google.com/sdk/docs/initializing
  ```
  $ gcloud auth login
  $ gcloud config set project <PROJECT_ID>
  ```
* Confirm gcloud is configured correctly:
  ```
  $ gcloud config list
  ```
* Create the resources in GCP using Terraform:
  ```
  $ terraform init
  $ terraform apply --auto-approve -var="project=<YOUR_PROJECT_ID>"
  ```
* Verify that the new resources have been created:
  * From CLI:
  ```
  TODO
  ```
  * From UI: 
    * GKE Cluster: #TODO
    * CloudSQL Database: #TODO
* Configure kubectl:
```
TODO
```
* Confirm kubectl is configured:
```
kubectl get pods --all-namespaces
```
* Navigate to the `helm` directory and fill in the missing values in
`helm/values.yaml` (search for `# UPDATE THE VALUE` comments)
  * The database hostname was printed by the `terraform apply` command and by
  the `#TODO` command
  * The Klaytn network API endpoint should be something you have.
* Deploy the services to Kubernetes:
```
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
helm install graph-indexer . --create-namespace --namespace=graph-indexer
```
* Confirm services were deployed: 
```
helm list --all-namespaces
kubectl get pods --all-namespaces
```
* Get the external IP of the Ingress controller:
```
kubectl get all -n ingress-controller
```
* Navigate to the `http://<EXTERNAL_IP>/subgraphs/graphql` url in a browser to
confirm it is working correctly

> **_NOTE:_** : To destroy everything, simply run `terraform destroy --auto-approve`

> **_NOTE:_** : You can now return to the root documentation and continue the guide. 

### (OPTIONAL) Making everything production-ready

* Terraform uses a local statefile. #TODO
> **_NOTE:_** : The additional configuratios should go in `provider.tf`.  After 
updating the terraform configs, you would have to run `terraform init` to start
storing the state remotely.
* Restrict network access
  * Modify the `gke_management_ips` variable in the
  `infrastructure/gcp/variables.tf` file to only allow access from your network.
  * Modify the `nginx.ingress.kubernetes.io/whitelist-source-range` variable
  in the `helm/values.yaml` file to only allow access from your network.
> **_NOTE:_** : After updating the configs you would have to run both
`terraform apply` and `helm upgrade graph-indexer . --namespace=graph-indexer`
to apply them.
* The database credentials are currently stored in plain text.
  * Remove the default values of `postgresql_admin_user` and
  `postgresql_admin_password` from `infrastructure/gcp/variables.tf`.
  * Define new values in a `.tfvars` file in the same directory like this:
  ```
  postgresql_admin_user = "<your-desired-username>"
  postgresql_admin_password = "<your-desired-password>"
  ```
  > **_NOTE:_** : Do NOT commit `.tfvars` to source control.
  * Terraform apply the changes: `terraform apply --auto-approve`
  * Create a Kubernetes secret:
  ```
    kubectl create secret generic postgresql.credentials \
    --namespace=graph-indexer \
    --from-literal=username="<your-desired-username>" \
    --from-literal=password="<your-desired-password>"
  ```
  * Update the Helm charts to use the new secret:
    * Remove the `username` and `password` variables from `values.yaml`
    * Edit `deployment-index-node` and `deployment-query-node` and replace this
    part:
    ```
        - name: postgres_user
          value: {{ index  .Values.CustomValues "postgress" "indexer" "username" }}
        - name: postgres_pass
          value: {{ index  .Values.CustomValues "postgress" "indexer" "password" }}
    ```
    with:
    ```
        - name: postgres_user
          valueFrom:
            secretKeyRef:
                name: postgresql.credentials
                key: username
        - name: postgres_pass
          valueFrom:
            secretKeyRef:
                name: postgresql.credentials
                key: password
    ```
  * Apply the changes: `helm upgrade graph-indexer . --namespace=graph-indexer`
* Configure a DNS entry and set up certificates for the kubernetes nginx-ingress:
#TODO
* For monitoring:
  * A prometheus node which scrapes metrics from indexer nodes is available
  at `http://<EXTERNAL_IP>/prometheus/graph`. You could configure it as a 
  data source in Grafana Cloud. Follow the instructions in 
  [this guide](https://grafana.com/docs/grafana-cloud/kubernetes-monitoring/prometheus/prometheus_operator/#step-6--create-a-kubernetes-secret-to-store-grafana-cloud-credentials).
  * An alertmanager node is available at `http://<EXTERNAL_IP>/alertmanager`. 
  You could configure it to send Prometheus alerts to Pagerduty. 
    * Create a Pagerduty API key and configure it the `alertmanager.yaml` file.
    More information at: https://www.pagerduty.com/docs/guides/prometheus-integration-guide/
    * For creating alerts, use the `prometheusRules.yaml` snippetfile.
  > **_NOTE:_** : Consider storing the Pagerduty API key in a Kubernetes secret. 

> **_NOTE:_** : You have to run `helm upgrade graph-indexer . --namespace=graph-indexer`
to apply the changes. 