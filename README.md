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
* Configure your AWS CLI (and implicitly terraform): https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-config
  ```
  $ aws configure
  AWS Access Key ID [None]: <Your-Key-ID>
  AWS Secret Access Key [None]: <Your-Secret-Access-Key>
  Default region name [None]: us-west-2
  Default output format [None]: json
  ```
  > **_NOTE:_** : Instructions for getting the credentials are in the same userguide. 

  > **_NOTE:_** : At the end of this step you should have credentials configured in your `$HOME/.aws/credentials`
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
* Update the missing values in `helm/values.yaml` (search for `# UPDATE THE VALUE` comments)
  * The database hostname was printed by the `terraform apply` command and by the `aws rds describe-db-instances` command (the `Address` field)
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
* Navigate to the `http://<EXTERNAL_IP>/subgraphs/graphql` url in a browser to confirm it is working correctly

## Subgraphs

## Queries