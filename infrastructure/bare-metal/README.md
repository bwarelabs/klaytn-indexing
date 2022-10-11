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
* Edit `docker-compose.yml` and fill in your Klaytn API URL. Search for `KLAYTN_API_URL`.
* Copy the `docker-compose.yml` file somewhere on your host.
* Start the docker containers. Run this command from the same folder as your
`docker-compose.yml`:
```
docker compose up
```
* Verify everything is running correctly:
    * Check the running docker containers:
    ```
        docker ps
    ```
    You should see the following containers: `ipfs`, `#TODO`
    * Verify ports used by these services are open:
    ```
        netstat -nltp
    ```
    You should see the following ports: `5001`, `#TODO`
    * Check the output of these services:
    ```
        docker logs ipfs
    ```
    We just need to make sure there are no error messages. 
* #TODO
