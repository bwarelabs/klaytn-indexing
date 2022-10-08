# AWS EKS

These instructions will walk you through spinning up an EKS cluster and an RDS
database in AWS using Terraform. Afterwards, we will use helm and kubectl to 
deploy a Graph Node (+ other helper services) on top of them. 

### Prerequisites

* An AWS account: https://aws.amazon.com/account/sign-up
* Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
* Kubectl: https://kubernetes.io/docs/tasks/tools/
* Helm: https://helm.sh/docs/intro/install/
* A Klaytn API Endpoint

### Setup

* Configure your AWS CLI (and implicitly Terraform): 
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config
  ```
  $ aws configure
  AWS Access Key ID [None]: <Your-Key-ID>
  AWS Secret Access Key [None]: <Your-Secret-Access-Key>
  Default region name [None]: us-west-2
  Default output format [None]: json
  ```
  > **_NOTE:_** : Instructions for getting the credentials are in the same 
  user guide. 

  > **_NOTE:_** : At the end of this step you should have credentials 
  configured in your `$HOME/.aws/credentials`
* Create the resources in AWS using Terraform:
  ```
  $ terraform init
  $ terraform apply --auto-approve
  ```
* Verify that the new resources have been created:
  * From CLI:
  ```
  $ aws eks list-clusters --region=us-west-2
  $ aws rds describe-db-instances --region=us-west-2
  ```
  * From UI: 
    * EKS Cluster: https://us-west-2.console.aws.amazon.com/eks/home?region=us-west-2#/clusters
    * RDS Database: https://us-west-2.console.aws.amazon.com/rds/home?region=us-west-2#databases: 
* Configure kubectl:
```
aws eks update-kubeconfig --name graph-indexer --region=us-west-2
```
* Confirm kubectl is configured:
```
kubectl get pods --all-namespaces
```
* Navigate to the `helm` directory and fill in the missing values in
`helm/values.yaml` (search for `# UPDATE THE VALUE` comments)
  * The database hostname was printed by the `terraform apply` command and by
  the `aws rds describe-db-instances --region=us-west-2` command (the `Address` field)
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

* Terraform uses a local statefile. To make it persistent, you would have to
create an S3 Bucket and a DynamoDB table manually following the instructions on
this page: https://www.terraform.io/language/settings/backends/s3
> **_NOTE:_** : The additional configuratios should go in `provider.tf`.  After 
updating the terraform configs, you would have to run `terraform init` to start
storing the state remotely.
* Restrict network access
  * Modify the `eks_management_ips` variable in the
  `infrastructure/aws/variables.tf` file to only allow access from your network.
  * Modify the `nginx.ingress.kubernetes.io/whitelist-source-range` variable
  in the `helm/values.yaml` file to only allow access from your network.
> **_NOTE:_** : After updating the configs you would have to run both
`terraform apply` and `helm upgrade graph-indexer . --namespace=graph-indexer`
to apply them.
* The database credentials are currently stored in plain text.
  * Remove the default values of `postgresql_admin_user` and
  `postgresql_admin_password` from `infrastructure/aws/variables.tf`.
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
https://aws.amazon.com/premiumsupport/knowledge-center/eks-set-up-externaldns/
> **_NOTE:_** : We already have an nginx-ingress deployed, just configure
`external-dns.alpha.kubernetes.io/hostname: DOMAIN_NAME` when you get to that step.

> **_NOTE:_** : Consider creating Terraform resources for the new IAM resources
and Helm configurations for the external-dns pod.
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