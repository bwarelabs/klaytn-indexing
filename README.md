# Indexing the Klaytn network

Set up a Kubernetes cluster of 
[Graph nodes](https://github.com/graphprotocol/graph-node) that index the 
[Klaytn network](https://klaytn.foundation/) according to the input 
[subgraphs](https://thegraph.com/docs/en/developing/creating-a-subgraph/)
which you can use to execute
[GraphQL queries](https://thegraph.com/docs/en/querying/graphql-api/).

## Infrastructure

For setting up the infrastructure, we will use Terraform and AWS. 

> **_NOTE:_** : Instructions for other Cloud platforms will be coming
in the future. 

### Prerequisites

* Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
* Kubectl: https://kubernetes.io/docs/tasks/tools/
* Helm: https://helm.sh/docs/intro/install/
* An AWS account: https://aws.amazon.com/account/sign-up
* A Klaytn API Endpoint

### Create the infrastructure

We will use terraform to create the infrastructure in AWS:
* Configure your AWS CLI (and implicitly terraform): 
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
* Navigate to the `infrastructure/aws` directory and run these commands:
  ```
  $ terraform init
  $ terraform apply --auto-approve
  ```
* Verify that the new resources have been created:
  * From CLI:
  ```
  $ aws eks list-clusters
  $ aws rds describe-db-instances
  ```
  * From UI: 
    * EKS Cluster: https://us-west-2.console.aws.amazon.com/eks/home?region=us-west-2#/clusters
    * RDS Database: https://us-west-2.console.aws.amazon.com/rds/home?region=us-west-2#databases: 
* Configure kubectl:
```
aws eks update-kubeconfig --name graph-indexer
```
* Confirm kubectl is configured:
```
kubectl get pods --all-namespaces
```
* Update the missing values in `helm/values.yaml` (search for 
`# UPDATE THE VALUE` comments)
  * The database hostname was printed by the `terraform apply` command and by
  the `aws rds describe-db-instances` command (the `Address` field)
  * The Klaytn network API endpoint should be something you have.
* Navigate to the `helm` directory and run these commands:
```
helm install graph-indexer . --create-namespace --namespace=graph-indexer
helm list --all-namespaces
kubectl get pods --all-namespaces
```
* Get the external IP of the Ingress controller:
```
kubectl get all -n ingress-controller
```
* Navigate to the `http://<EXTERNAL_IP>/query/subgraphs/graphql` url in a browser to
confirm it is working correctly

> **_NOTE:_** : To destroy everything, simply run `terraform destroy --auto-approve`

### (OPTIONAL) Making the setup production-ready

* Terraform uses a local statefile. To make it persistent, you would have to
create an S3 Bucket and a DynamoDB table manually following the instructions on
this page: https://www.terraform.io/language/settings/backends/s3
> **_NOTE:_** : After updating the terraform configs, you would have to run
`terraform init` again.
* Restrict network access
  * Modify the `eks_management_ips` variable in the
  `infrastructure/aws/variables.tf` file to only allow access from your network.
  * Modify the `nginx.ingress.kubernetes.io/whitelist-source-range` variable
  in the `helm/values.yaml` file to only allow access from your network.
> **_NOTE:_** : After updating the configs you would have to run both
`terraform apply` and `helm upgrade graph-indexer . --namespace=graph-indexer`
* The database credentials are currently stored in plain text.
  * Remove the default values of `postgresql_admin_user` and
  `postgresql_admin_password` from `infrastructure/aws/variables.tf`.
  * Define the new values in a `.tfvars` file in the same folder like this:
  ```
  postgresql_admin_user = "<your-desired-username>"
  postgresql_admin_password = "<your-desired-password>"
  ```
  > **_NOTE:_** : Do NOT commit `.tfvars` to source control.

  > **_NOTE:_** : You would have to `terraform apply` the changes.
  * Define a new 
  [kubernetes secret terraform resource](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret)
  which references the 2 variables and then update the helm charts to reference
  the secret. 
* Configure a DNS entry and set up certificates for the kubernetes 
nginx-ingress

## Subgraphs

### Prerequisites

* The Graph CLI: https://thegraph.com/docs/en/cookbook/quick-start/#1-install-the-graph-cli 

### Deploying

* Run these commands from your repository:
```
graph create example --node http://<EXTERNAL_IP>/index
graph deploy example --ipfs http://<EXTERNAL_IP>/ipfs --node http://<EXTERNAL_IP>/index
```
> **_NOTE:_** : If you do not have a subgraph, you can use this example one:
https://github.com/graphprotocol/example-subgraph. Don't forget to change the
network in `subgraph.yaml` to `klaytn`.

* To check that indexing has started run the following command:
```
kubectl logs service/index-node-klaytn-service -n graph-indexer | tail -n 100
```
> **_NOTE:_** : You will have to wait for a few minutes for blocks to be 
ingested before running queries.
* Navigate to `http://<EXTERNAL_IP>/query/subgraphs/name/<SUBGRAPH_NAME>/graphql`
and run queries. Here's an example:
```
query MyQuery {
  _meta {
    block {
      number
    }
  }
}
```
> **_NOTE:_** : For the example, `SUBGRAPH_NAME` is `example`

## Queries