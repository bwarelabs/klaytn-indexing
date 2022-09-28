# Indexing the Klaytn network

Set up a graph node that indexes the 
[Klaytn network](https://klaytn.foundation/) according to input 
[subgraphs](https://thegraph.com/docs/en/developing/creating-a-subgraph/)
which then allows you to execute 
[GraphQL queries](https://thegraph.com/docs/en/querying/graphql-api/)
against it.

## Infrastructure

For setting up the infrastructure, we will use Terraform and AWS. 

> **_NOTE:_** : Instructions for other Cloud platforms will be coming
in the future. 

We will provision a Kubernetes cluster where we will deploy a 
[graph-node](https://github.com/graphprotocol/graph-node) and all
the other necessary components for the graph-node to work correctly.

### Prerequisites

* Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started



## Subgraphs

## Queries