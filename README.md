# docker-dropbear-rfwd
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/rokiden/dropbear-rfwd)

Small container with minimal dropbear-ssh-server for remote tcp forwarding. Designed for accessing services behind NAT with attention to security of jump server.
Dropbear building from sources with minimal configuartion supports only remote tcp forwarding and auth by pubkey.

## Build
```
git clone https://github.com/rokiden/docker-dropbear-rfwd.git
cd docker-dropbear-rfwd
docker build . -t rokiden/dropbear-rfwd
```
## Usage
### On jump server:
 * expose ssh port
 * bind /keys volume with authorized_keys and dropbear_ecdsa_host_key (automatically created if not exists)
 * (option) expose forwarded service port
 * (option) set UUID env used for authorized_keys permissions fix (default 1000)
 * (option) pass dropbear args (-K 10)
```
docker run -d --name dropbear-rfwd -p4444:22 -p4422:2000 -v /opt/dropbear-rfwd/keys:/keys -e UUID=1111 rokiden/dropbear-rfwd -K 10
```

### On remote server (behind NAT):
forward remote ssh to jump server
```
ssh -p4444 -N -R 0.0.0.0:2000:localhost:22 -o ServerAliveInterval=10 user@jump.server
```
or persistent forwarding with cron and autossh
```
@reboot bash -c "while :; do autossh -M 10000 -p4444 -N -R 0.0.0.0:2000:localhost:22 -o ServerAliveInterval=10 user@jump.server; sleep 5; done" >> /var/log/autossh.log 2>&1
```

### Tunnel usage:
After successfull connection, container listen forwarded port 2000 (optionally jump server listen container exposed 4422).

On jump server (172.17.0.3 is container ip)
```
ssh -p2000 remote-user@172.17.0.3
```
or from desktop if 4422 exposed
```
ssh -p4422 remote-user@jump.server
```
