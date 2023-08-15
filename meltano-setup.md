

# Meltano

## Meltano Pre-Reqs

https://www.centlinux.com/2022/06/how-to-install-python-310-on-rocky-linux.html

``` bash
sudo dnf install -y curl gcc openssl-devel bzip2-devel libffi-devel zlib-devel tar wget make sqlite-devel
cd /tmp
#Check for latest version here: https://www.python.org/ftp/python/
wget https://www.python.org/ftp/python/3.10.11/Python-3.10.11.tar.xz
sudo tar -xf Python-3.10.11.tar.xz -C /opt/
sudo chown matt:matt -R /opt/Python-3.10.11/
cd /opt/Python-3.10.11/
./configure --enable-optimizations --enable-loadable-sqlite-extensions 
make -j 2
sudo make altinstall

#The binary is `python3.10`, optionally add the following line to your `~/.bashrc` file:
  alias python3="python3.10"

source ~/.bashrc

```


Optional - Mount a location that you can see the files that Meltano creates (say within VSCode from your desktop)
``` bash
sudo mkdir /media/devspace
sudo mount -t nfs -o vers=4,nolock,local_lock=all 192.168.2.22:/volume1/Dropbox/devspace /media/devspace/

sudo useradd dev -u 1025 -G wheel
sudo passwd dev
su dev

sudo yum install cifs-utils
# mount -t cifs -o username=guest,password=Password1 //192.168.2.22/Drobox /media/devspace




sudo chown matt:matt /media/devspace/
sudo chmod 770 /media/devspace
# Then mount this same location on your workstation...
```



## Install and Configure Meltano

``` bash
# Install Meltano

python3 -m pip install --user pipx
python3 -m pipx ensurepath
source ~/.bashrc
pipx install meltano
meltano --version

# Initialise Meltano
mkdir meltano-projects
cd meltano-projects
meltano init my-meltano-project
cd my-meltano-project

# Setup Git
git config --global --add safe.directory /media/devspace/meltano-projects/my-meltano-project
git config --global user.email "test@test.com"
git config --global user.name "Test"

# Add version control
git init
git add --all
git commit -m 'Initial Meltano project'

#Set to dev environment
meltano environment list
export MELTANO_ENVIRONMENT=dev


# View all extractors
meltano discover extractors
meltano discover extractors | grep git

# Install an extractor
meltano add extractor tap-gitlab
#To learn more about extractor 'tap-gitlab', visit https://hub.meltano.com/extractors/tap-gitlab--meltanolabs

# if you need to cache plugins offline:
# https://docs.meltano.com/guide/plugin-management/#installing-plugins-from-a-custom-python-package-index-pypi

meltano config tap-gitlab set --interactive

## SKIP to video content: 
meltano add extractor tap-github
meltano config tap-github set repository 'meltano/meltano'
meltano config tap-github set start_date 2022-06-01T:00:010:00Z

# Set which stream we want to pull
meltano --no-environment select tap-github commits "*"


```

