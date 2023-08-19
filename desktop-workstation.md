

 Install a Rocky Linux 8 server with GUI

 # Enabled RDP
If your server cannot do x-forwarding via SSH (which I think is a better option than RDP), you can instead enable RDP: 

https://linux.how2shout.com/how-to-connect-rocky-linux-8-via-windows-rdp-protocol/

``` bash
sudo dnf install epel-release
sudo dnf update
sudo dnf install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo systemctl status xrdp
sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --reload

```


# Install Dev Tools

VSCode: 
https://code.visualstudio.com/docs/setup/linux

``` bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf install git code # or code-insiders

# There is an alternate to download the rpm and offline install: https://go.microsoft.com/fwlink/?LinkID=760867
```

Podman (aliased as `docker`)
``` bash
sudo dnf install podman podman-docker
docker -v
```


