# Indexing the Klaytn network

Set up a [Graph node](https://github.com/graphprotocol/graph-node)
that indexes the 
[Klaytn network](https://klaytn.foundation/) according to the input 
[subgraphs](https://thegraph.com/docs/en/developing/creating-a-subgraph/)
which you can use to execute
[GraphQL queries](https://thegraph.com/docs/en/querying/graphql-api/).

## Infrastructure

There are multiple options for setting up the infrastructure. Navigate
to the `infrastructure/<option>` folder and follow the instructions from
there. 

After you have provisioned the infrastructure, return to this guide.

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
network to `klaytn` in `subgraph.yaml`.

> **_NOTE:_** : You will have to wait for a few minutes for blocks to be 
ingested before running queries. You could check the output of the indexer node
to make sure it is working.

### Creating

To learn more about creating custom subgraphs take a look at 
https://thegraph.com/docs/en/developing/creating-a-subgraph/

## Queries

* Navigate to `http://<EXTERNAL_IP>/subgraphs/name/<SUBGRAPH_NAME>/graphql`
to run queries. Here's an example:
```
query MyQuery {
  _meta {
    block {
      number
    }
  }
}
```
> **_NOTE:_** : For the example subgraph, `SUBGRAPH_NAME` is `example`