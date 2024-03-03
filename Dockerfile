FROM alpine:latest
LABEL maintainer.name="shawn.qian" \
    maintainer.email="shown1985@gmail.com" \
    version="1.7.3-shawn-alpha.0" \
    description="OpenVPN client and socks5 server configured for SurfShark VPN"
WORKDIR /vpn
ENV SURFSHARK_USER=
ENV SURFSHARK_PASSWORD=
ENV SURFSHARK_COUNTRY=
ENV SURFSHARK_CITY=
ENV OPENVPN_OPTS=
ENV CONNECTION_TYPE=tcp
ENV LAN_NETWORK=
ENV CREATE_TUN_DEVICE=
ENV ENABLE_MASQUERADE=
ENV OVPN_CONFIGS=
ENV ENABLE_KILL_SWITCH=true
ENV DNS_SERVER 8.8.8.8
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s CMD curl -s https://api.surfshark.com/v1/server/user | grep '"secured":true'
COPY startup.sh .
COPY sockd.conf /etc/
COPY sockd.sh .
RUN apk add --update --no-cache openvpn wget unzip coreutils curl ufw dante-server \
    && chmod +x ./startup.sh \
    && chmod +x ./sockd.sh
ENTRYPOINT [ "./startup.sh" ]
