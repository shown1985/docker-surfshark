# docker-surfshark

Docker container with OpenVPN client preconfigured for SurfShark

This is a [multi-arch](https://medium.com/gft-engineering/docker-why-multi-arch-images-matters-927397a5be2e) image, updated automatically thanks to [GitHub Actions](https://github.com/features/actions).

Its purpose is to provide the [SurfShark VPN](https://surfshark.com/) to all your containers. 

The link is established using the [OpenVPN](https://openvpn.net/) client.

Shadowsocks server added, so it can pass through via the surfshark VPN for using

## Configuration

The container is configurable using different environment variables:

| Name | Mandatory | Description |
|------|-----------|-------------|
|SURFSHARK_USER|Yes|Username provided by SurfShark|
|SURFSHARK_PASSWORD|Yes|Password provided by SurfShark|
|SURFSHARK_COUNTRY|No|The country, supported by SurfShark, in which you want to connect|
|SURFSHARK_CITY|No|The city of the country in which you want to connect|
|OPENVPN_OPTS|No|Any additional options for OpenVPN|
|CONNECTION_TYPE|No|The connection type that you want to use: tcp, udp|
|LAN_NETWORK|No|Lan network used to access the web ui of attached containers. Can be comma seperated for multiple subnets Comment out or leave blank: example 192.168.0.0/24|
|CREATE_TUN_DEVICE|No|Creates the TUN device, useful for NAS users|
|ENABLE_MASQUERADE|No|Masquerade NAT allows you to translate multiple IP addresses to another single IP address.|
|OVPN_CONFIGS|No|Manually provide the path used to read the "Surfshark_Config.zip" file (contains Surshark's OpenVPN configuration files)
|ENABLE_KILL_SWITCH|No|Enable the kill-switch functionality

`SURFSHARK_USER` and `SURFSHARK_PASSWORD` are provided at [this page](https://my.surfshark.com/vpn/manual-setup/main/openvpn).

<p align="center">
    <img src="https://user-images.githubusercontent.com/12913436/180714205-095e891e-4636-43c2-918c-5379f075d993.png" alt="SurfShark credentials"/>
</p>

## Execution

You can run this image using [Docker compose](https://docs.docker.com/compose/) and the [sample file](./docker-compose.yml) provided.  
**Remember: if you want to use the web gui of a container, you must open its ports on `docker-surfshark` as described below.**

```
version: "2"

services: 
    surfshark:
        image: shown1985/docker-surfshark
        container_name: surfshark
        environment: 
            - SURFSHARK_USER=YOUR_SURFSHARK_USER
            - SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD
            - SURFSHARK_COUNTRY=us
            - SURFSHARK_CITY=lax
            - CONNECTION_TYPE=tcp
            - LAN_NETWORK=172.17.0.0/24      #Optional - Used to access attached containers web ui
        cap_add: 
            - NET_ADMIN
        devices:
            - /dev/net/tun
        ports:
            - 8388:8388 #Port for ss
        restart: unless-stopped
        dns:
            - 8.8.8.8
            - 223.5.5.5
    service_test:
        image: byrnedo/alpine-curl
        container_name: alpine
        command: -L 'https://ipinfo.io'
        depends_on: 
            - surfshark
        network_mode: service:surfshark
        restart: always
    ss:
        image: dockage/shadowsocks-server:latest
        container_name: ss    
        network_mode: service:surfshark
        restart: unless-stopped  
```

Or you can use the standard `docker run` command.

```sh
sudo docker run -it --cap-add=NET_ADMIN --device /dev/net/tun --name CONTAINER_NAME -e SURFSHARK_USER=YOUR_SURFSHARK_USER -e SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD shown1985/docker-surfshark:latest
```

If you want to attach a container to the VPN, you can simply run:

```sh
sudo docker run -it --net=container:CONTAINER_NAME alpine /bin/sh
```

If you want access to an attached container's web ui you will also need to expose those ports.  
The attached container must not be started until this container is up and fully running.

If you face network connection problems, I suggest you to set a specific DNS server for each container.

Alternatively, if your software supports it, you can use the socks5 server embedded in this container. It will redirect your traffic through the Surfshark's VPN.

## Provide OpenVPN Configs Manually

Sometimes the startup script fails to download OpenVPN configs file from Surfshark's website, possibly due to the DDoS protection on it.


To avoid it, you can provide your own `Surfshark_Config.zip` file, downloading it from [here](https://my.surfshark.com/vpn/api/v1/server/configurations).

Then, you **must** make the `zip` available inside the container, using a [bind mount](https://docs.docker.com/storage/bind-mounts/) or a [volume](https://docs.docker.com/storage/volumes/).

Finally, you **must** set the `OVPN_CONFIGS` environment variable.