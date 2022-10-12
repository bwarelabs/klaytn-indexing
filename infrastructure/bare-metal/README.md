# Bare Metal

These instructions will walk you through spinning up a Graph node on a generic
Linux host.

### Prerequisites

* A Linux machine with access to the internet.
* Sudo privileges on this machine.
* A Klaytn API Endpoint.

### Setup

> **_NOTE:_** : These instructions were tested on Ubuntu 22.04 LTS

* Connect to your machine. 
* We will run services in docker, so we have to install it first. The way to
do it is described
[here](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

> **_NOTE:_** : It might be useful to allow non-root users to run docker too: 
`sudo chmod 666 /var/run/docker.sock`

* Configure docker to start automatically on boot:
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
* Install other useful tools for debugging issues:
```
sudo apt install net-tools
```
* Copy the `nginx.conf` file to `/etc/nginx/nginx.conf` on your host.

> **_NOTE:_** : You might first have to create the directory: `sudo mkdir -p /etc/nginx`

* Edit `docker-compose.yml` and fill in your Klaytn API URL. Search for `KLAYTN_API_URL`.
* Copy the `docker-compose.yml` file somewhere on your host.
* Start the docker containers. Run this command from the same folder as your
`docker-compose.yml`:
```
docker compose up -d
```
* Verify everything is running correctly:
    * Check the running docker containers:
    ```
        docker ps
    ```
    You should see the following containers: `query-node`, `index-node`, `ipfs`, `postgres`, `nginx`
    * Verify ports used by these services are open:
    ```
        netstat -nltp
    ```
    You should see the following ports: `80`, `5001`, `5432`, `8000`, `8020`
    * Check if the index-node has started sync-ing:
    ```
        docker logs index-node
    ```
    You should see something like this:
    ```
    Oct 12 14:52:17.601 INFO Syncing 84 blocks from Ethereum, code: BlockIngestionLagging, blocks_needed: 84, blocks_behind: 84, latest_block_head: 103684173, current_block_head: 103684089, provider: klaytn-rpc-0, component: BlockIngestor
    Oct 12 14:52:47.482 INFO Syncing 30 blocks from Ethereum, code: BlockIngestionLagging, blocks_needed: 30, blocks_behind: 30, latest_block_head: 103684203, current_block_head: 103684173, provider: klaytn-rpc-0, component: BlockIngestor
    Oct 12 14:52:58.759 INFO Syncing 11 blocks from Ethereum, code: BlockIngestionStatus, blocks_needed: 11, blocks_behind: 11, latest_block_head: 103684214, current_block_head: 103684203, provider: klaytn-rpc-0, component: BlockIngestor
    ```
* Navigate to the `http://<EXTERNAL_IP>/subgraphs/graphql` url in a browser to
confirm it is working correctly

> **_NOTE:_** : If you are doing everything on localhost, then navigate to
`http://localhost/subgraphs/graphql`

> **_NOTE:_** : To stop the services run `docker compose down`