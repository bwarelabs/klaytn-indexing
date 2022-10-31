# Indexing the Klaytn network

The purpose of this documentation is to take you through all the necessary steps required to set-up a [Graph node](https://github.com/bwarelabs/graph-node) specifically customized for optimized indexing on the
[Klaytn network](https://klaytn.foundation/).
The entire set up is based on the input subgraph described in the `subgraph-demo` folder.

You will find that the documentation is separated in two sections describing the process of running an indexer node, and providing working examples on how to develop, build and query a subgraph.

## About the Klaytn Network

According to the official description Klaytn is a highly optimized, BFT-based, public blockchain that aims to achieve enterprise-grade reliability employing Key design characterisitcs such immediate finality, high throughput for real-world use cases and lower costs for dApps.

The Klaytn evm-based mainnet, Cypress, was launched in 2019 and it features low gas prices, 1-second block generation and confirmation time and 4000 transactions per second.

## Infrastructure

There are multiple options for setting up the infrastructure. Navigate
to the `infrastructure/<option>` folder and follow the instructions from
there. 

After you have provisioned the infrastructure, return to this guide.

## Subgraphs

For a working example as well as comprehensive documentation about how to develop, run and query a subgraph navigate to the [subgraph-demo](https://github.com/bwarelabs/klaytn-indexing/tree/main/subgraph-demo) folder and follow the steps there.
By goingh through al the steps in this guide you should be able to have a working indexing solution up and running on Klaytn using the Graph tech

This tutorial was created by the team at [Bware Labs](https://bwarelabs.com). If you require further assitance or you are in need of professional customized indexing solutions please don't hesitate to contact us at enterprise@bwarelabs.com