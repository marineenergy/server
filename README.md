# mhk-env_server-software
server software install using Docker

Contents:
<!--
To update table of contents run: `cat README.md | ./gh-md-toc -`
Uses: https://github.com/ekalinin/github-markdown-toc
-->

* [Server software](#server-software)
* [Shell into server](#shell-into-server)
* [Create Server on DigitalOcean](#create-server-on-digitalocean)
* [Install Docker](#install-docker)
   * [docker](#docker)
   * [docker-compose](#docker-compose)
* [Build containers](#build-containers)
   * [Test webserver](#test-webserver)
* [Setup domain iea-ne.us](#setup-domain-iea-neus)
* [Run docker-compose](#run-docker-compose)
* [marineenergy.app manual post-docker install steps](#mhk-envus-manual-post-docker-install-steps)
   * [rstudio-shiny](#rstudio-shiny)
* [Docker maintenance](#docker-maintenance)
   * [Push docker image](#push-docker-image)
   * [Develop on local host](#develop-on-local-host)
   * [Operate on all docker containers](#operate-on-all-docker-containers)
   * [Inspect docker logs](#inspect-docker-logs)
* [migrate /share to 500 GB volume](#migrate-share-to-500-gb-volume)
   * [check drives](#check-drives)
   * [make space](#make-space)
   * [mount](#mount)
* [TODO](#todo)

## Server software

- Website:<br>
  **www.\***, **marineenergy.app**
  - [Nginx](https://www.nginx.com/)
  - [Rmarkdown website](https://bookdown.org/yihui/rmarkdown/rmarkdown-site.html)
- Analytical apps:
  - [Shiny](https://shiny.rstudio.com)<br>
    **shiny.\***
  - [RStudio](https://rstudio.com/products/rstudio/#rstudio-server)<br>
    **rstudio.\***
- Spatial engine:
  - [GeoServer](http://geoserver.org)<br>
    **gs.\***
  - [PostGIS](https://postgis.net)<br>
    iea-ne.us **:5432**

### Development environments

We can edit code in **rstudio** and access the same database. In cases where the tables change, let's just create new tables or add a column like production = T/F or some such within the existing datase.

- Website:<br>
  **www-dev.\***, **marineenergy.app**
  - [Nginx](https://www.nginx.com/)
  - [Rmarkdown website](https://bookdown.org/yihui/rmarkdown/rmarkdown-site.html)

And for Shiny apps, we'll just create *_dev symbolic links (`ln -s`) under `/srv/shiny-server/`.
  
  
### Working Development and Production environments


- static web site:
  - production:  
    - filesystem: `/share/github/mhk-env.github.io`
    - endpoint: https://marineenergy.app
  - development: 
    - filesystem: `/share/github/mhk-env.github.io_dev`
    - endpoint: https://www-dev.marineenergy.app
- interactive shiny app:
  - filesystems:
    - production:  `/share/github/mhk-env_shiny-apps`
    - development: `/share/github/mhk-env_shiny-apps_dev`
  - a single app folder: `report`
    - setup once the symbolic link to the dev version of the app folder: `ln -s /share/github/mhk-env_shiny-apps_dev/report /srv/shiny-server/report-dev`
    - endpoint: https://shiny.marineenergy.app/report-dev

To make changes to the code above (eg either website or Shiny app):

1. Log into https://rstudio.marineenergy.app
1. Open the project by 2x-clicking in the Files pane: to {filesystem}/*.Rproj
1. Create or change to the branch of interest in the Git pane
1. Make changes, git commit (possibly mentioning the issue #) and push them.
1. Visit the https://github.com/mhk-env/{repo}
1. When ready to merge with production, create a new Pull Request selecting the branch. Merge pull request. Visit the production filesystem and do a git pull.


## Containerization

- Containerized using:
  - [docker](https://docs.docker.com/engine/installation/)
  - [docker-compose](https://docs.docker.com/compose/install/)
  - [nginx-proxy](https://github.com/jwilder/nginx-proxy)

## Shell into server

Secure shell (SSH), eg for Ben Best on Mac Terminal:

```bash
ssh bbest@marineenergy.app
```

### Setup ssh keys

See [How To Set Up SSH Keys | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2).

```bash
ssh-keygen -t rsa
ssh-copy-id bbest@marineenergy.app
# Using password in `~/private/password_mhk-env.us`
```

## Create Server on DigitalOcean

Folks at Integral already handled this, but here's how I handled this for [marinebon/iea-server](https://github.com/marinebon/iea-server)...

Create droplet at https://digitalocean.com with ben@ecoquants.com (Google login):

- Choose an image : Distributions : Marketplace :
  - **Docker** by DigitalOcean VERSION 18.06.1 OS Ubuntu 18.04
- Choose a plan : Standard :
  - _small_:
    - **$40/mo** $0.060 /hour
    - 8 GB / 4 CPUs
    - 160 GB SSD disk
    - 5 TB transfer
- Choose a datacenter region :
  - **San Francisco**
- Authentication :
  - **One-time password**
    Emails a one-time root password to you (less secure)
- How many Droplets?
  - **1  Droplet**
- Choose a hostname :
  - _smallest_:
    - **marineenergy.app**

Add an external disk drive, especially for downloading and consuming the MarineCadastre datasets:
  - **$50/mo** for 500 GB volume


Email recieved with IP and temporary password:

- _marineenergy.app_:

  > Your new Droplet is all set to go! You can access it using the following credentials:
  > 
  > Droplet Name: marineenergy.app
  > IP Address: 157.245.189.38
  > Username: root
  > Password: 513dbca94734429761db936640

Have to reset password upon first login.

Saved password on my Mac to a local file:

```bash
ssh root@157.245.189.38
# enter password from above
# you will be asked to change it upon login
```

For instance (replace `S3cr!tpw` with your own password):

```bash
echo S3cr!tpw > ~/private/password_mhk-env.us
cat ~/private/password_mhk-env.us
```

Then you can login  via:

```bash
sshpass -f ~/My\ Drive/private/password_mhk-env.us ssh bbest@marineenergy.app
```

## Install Docker

Since we used an image with `docker` and `docker-compose` already installed, we can skip this step.

References:

- [How To Install and Use Docker on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) for more.

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# add the GPG key for the official Docker repository to your system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add the Docker repository to APT sources 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# update the package database with the Docker packages from the newly added repo
sudo apt update

# install Docker
sudo apt install docker-ce
```

### docker

```bash
# confirm architecture
uname -a
# Linux docker-iea-ne 4.15.0-58-generic #64-Ubuntu SMP Tue Aug 6 11:12:41 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

# update packages
sudo apt update

# check that it’s running
sudo systemctl status docker
```

### docker-compose

References:

- [How To Install Docker Compose on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)

```bash
# check for latest version at https://github.com/docker/compose/releases and update in url
sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

# set the permissions
sudo chmod +x /usr/local/bin/docker-compose

# verify that the installation was successful by checking the version:
docker-compose --version
# docker-compose version 1.25.4, build 8d51620a
```


- [Install Docker Compose | Docker Documentation](https://docs.docker.com/compose/install/)


## Build containers

### Test webserver

Reference:

- [How To Run Nginx in a Docker Container on Ubuntu 14.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-run-nginx-in-a-docker-container-on-ubuntu-14-04)

```bash
docker run --name test-web -p 80:80 -d nginx

# confirm working
docker ps
curl http://localhost
```

returns:
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Turn off:

```bash
docker stop test-web
```

## Setup domain iea-ne.us

- Bought domain **marineenergy.app** for **$12/yr** with account bdbest@gmail.com.

- DNS matched to server IP `64.225.118.240` to domain **marineenergy.app** via [Google Domains]( https://domains.google.com/m/registrar/iea-ne.us/dns), plus the following subdomains added under **Custom resource records** with:

- Type: **A**, Data:**157.245.189.38** and Name:
  - **@**
  - **gs**
  - **rstudio**
  - **shiny**
- Name: **www**, Type: **CNAME**, Data:**marineenergy.app**

## Run docker-compose

References:

- [Quickstart: Compose and WordPress | Docker Documentation](https://docs.docker.com/compose/wordpress/)
- [docker-compose.yml · kartoza/docker-geoserver](https://github.com/kartoza/docker-geoserver/blob/master/docker-compose.yml)
- [How To Install WordPress With Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose)


First, you will create the environment `.env` file to specify password and host:

- NOTE: Set `PASSWORD`, substituting "S3cr!tpw" with your password. The [docker-compose.yml](https://github.com/BenioffOceanInitiative/s4w-docker/blob/master/docker-compose.yml) uses [variable substitution in Docker](https://docs.docker.com/compose/compose-file/#variable-substitution).

```bash
# get latest docker-compose files
git clone https://github.com/mhk-env/mhk-env_server-software.git
cd ~/mhk-env_server-software

# set environment variables
echo "PASSWORD=S3cr!tpw" > .env
# actual password on Ben's laptop: ~/private/password_mhk-env.us_server-software
echo 'HOST=marineenergy.app' >> .env
cat .env

# launch
docker-compose up -d

# Creating network "iea-server_default" with the default driver
# Creating volume "iea-server_postgis-backups" with default driver
# Creating volume "iea-server_geoserver-data" with default driver
# Creating volume "iea-server_postgis-data" with default driver
# Creating volume "iea-server_mysql-data" with default driver
# Creating volume "iea-server_wordpress-html" with default driver
# Creating volume "iea-server_shiny-apps" with default driver
# Creating volume "iea-server_erddap-data" with default driver
# Creating volume "iea-server_erddap-config" with default driver
# Creating volume "iea-server_nginx-html" with default driver
# Pulling postgis (kartoza/postgis:11.0-2.5)...
# 11.0-2.5: Pulling from kartoza/postgis
# 68ced04f60ab: Pull complete
# ...

# OR update
git pull; docker-compose up -d

# OR build if Dockerfile updated in subfolder
git pull; docker-compose up --build -d

# git pull; docker-compose up -d --no-deps --build erddap

# OR reload
docker-compose restart

# OR stop
docker-compose stop
```

## update docker compose images

bbest @ 2024-09-25

- e.g., update: [for Quarto upgrade to rocker/geospatial:4.4.1 (from 4.1.1) · marineenergy/server@2d089b5](https://github.com/marineenergy/server/commit/2d089b551e74628f5db9733bef0993ffdbe9db12)
- how: [How to update existing images with docker-compose? - Stack Overflow](https://stackoverflow.com/questions/49316462/how-to-update-existing-images-with-docker-compose)

```
WARN[0100] Found orphan containers (
[geoserver_server letsencrypt_server proxy_server nginx-dev_server nginx_server]
) for this project. If you removed or renamed this service in your compose file, 
you can run this command with the 
--remove-orphans flag to clean it up. 
```

```
# caddy fmt --overwrite Caddyfile

# marineenergy.app ----
# - [DNS](https://account.squarespace.com/domains/managed/marineenergy.app/dns/dns-settings) as ben@ecoquants.com
#   * @         A      206.189.173.168
#   * api       A      206.189.173.168
#   * rstudio   A      206.189.173.168
#   * shiny     A      206.189.173.168
#   * www       CNAME  marineenergy.app
#   * www-dev   A      206.189.173.168
```

```bash
docker compose pull

# to force rebuilding all
docker compose up --force-recreate --build -d
# OR to individually rebuild
docker compose build rstudio
docker compose up --build caddy

# to remove orphan containers
docker compose up --remove-orphans -d
# to start all daemons
docker compose up -d

docker image prune -f
```

### LOGS

```bash
docker compose pull
```

```
[+] Pulling 2/7
 ✔ nginx Skipped - No image to be pulled                                                                                                 0.0s 
 ✔ nginx-dev Skipped - No image to be pulled                                                                                             0.0s 
 ⠋ letsencrypt Pulling                                                                                                                   0.1s 
 ⠋ postgis Pulling                                                                                                                       0.1s 
 ⠋ rstudio Pulling                                                                                                                       0.1s 
 ⠋ proxy Pulling                                                                                                                         0.1s 
 ⠋ postgis-backup Pulling                                                                                                                0.1s 
WARNING: Some service image(s) must be built from source by running:
    docker compose build rstudio
error getting credentials - err: exit status 1, out: `GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.secrets was not provided by any .service files`
```

FIX, per - [docker build regression: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.secrets was not provided by any .service files · Issue #1078 · moby/buildkit](https://github.com/moby/buildkit/issues/1078#issuecomment-577450070)

```bash
sudo apt install gnome-keyring
```


## marineenergy.app manual post-docker install steps

TODO: fold into `docker-compose.yml`

Log into rstudio.marineenergy.app as admin and use the Terminal to:

```bash
sudo chown -R 777 /share
cd /share; mkdir github; cd github
git clone https://github.com/mhk-env/mhk-env.github.io.git
git clone https://github.com/mhk-env/mhk-env_shiny-apps.git
```

On Terminal for docker server with bbest@mhk-data-ubuntu: 

```bash
docker exec -it nginx bash
```

### rstudio-shiny

Haven't figured out how to RUN these commands after user admin is created in rstudio-shiny container.

1. Add shiny to staff so has permission to install libraries into `/usr/local/lib/R/site-library`.

```bash
sudo usermod -aG staff shiny
```

### shiny app symbolic links

```
cd /srv/shiny-server
sudo su
ln -s /share/github/mhk-env_shiny-apps/datasets datasets
ln -s /share/github/mhk-env_shiny-apps/report report0
ln -s /share/github/mhk-env_shiny-apps/report-gen report
ln -s /share/github/mhk-env_shiny-apps/search_tethys tethys
```

### postgis add postgres superuser

```bash
psql -h localhost -p 5432 -U admin -W gis

su postgres
psql

docker-compose up 2>> up_error.txt 1>> up_out.txt
```



```sql
CREATE ROLE postgres LOGIN SUPERUSER;


```

## Docker maintenance

### Push docker image

Since rstudio-shiny is a custom image `bdbest/rstudio-shiny:s4w`, I [docker-compose push](https://docs.docker.com/compose/reference/push/) to [bdbest/rstudio-shiny:s4w | Docker Hub](https://hub.docker.com/layers/bdbest/rstudio-shiny/s4w/images/sha256-134b85760fc6f383309e71490be99b8a50ab1db6b0bc864861f9341bf6517eca).

```bash
# login to docker hub
docker login --username=bdbest

# push updated image
docker-compose push
```

### Develop on local host

Note setting of `HOST` to `local` vs `iea-ne.us`:

```bash
# get latest docker-compose files
git clone https://github.com/marinebon/iea-server.git
cd ~/iea-server

# set environment variables
echo "PASSWORD=S3cr!tpw" > .env
echo "HOST=iea-ne.us" >> .env
cat .env

# stop all
docker stop $(docker ps -q)


# rename
docker rename nginx nginx_old
docker rename nginx-dev nginx-dev_old
docker rename postgis postgis_old
docker rename postgis postgis_new
docker rename postgis_old postgis
docker rename proxy proxy_old
docker rename rstudio rstudio_old
docker rename rstudio rstudio_new
docker rename rstudio_old rstudio
docker rename letsencrypt letsencrypt_old
docker rename geoserver geoserver_old



# launch
docker-compose up -d

# see all containers
docker ps -a
```

Then visit http://localhost or http://rstudio.localhost.

TODO: try migrating volumes in /var/lib/docker onto local machine.


### Operate on all docker containers

```bash
# stop all running containers
docker stop $(docker ps -q)

# remove all containers
docker rm $(docker ps -aq)

# remove all image
docker rmi $(docker images -q)

# remove all volumes
docker volume rm $(docker volume ls -q)

# remove all stopped containers
docker container prune
```

### Inspect docker logs

To tail the logs from the Docker containers in realtime, run:

```bash
docker-compose logs -f

docker inspect rstudio-shiny
```

## migrate `/share` to 500 GB volume

### check drives

See drives numbers or id by:

```bash
sudo fdisk -l
```

```
Disk /dev/vda: 160 GiB, 171798691840 bytes, 335544320 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 02CBFCD2-7495-4A08-A11B-28E7D3872FAA

Device      Start       End   Sectors   Size Type
/dev/vda1  227328 335544286 335316959 159.9G Linux filesystem
/dev/vda14   2048     10239      8192     4M BIOS boot
/dev/vda15  10240    227327    217088   106M Microsoft basic data

Partition table entries are not in disk order.


Disk /dev/sda: 500 GiB, 536870912000 bytes, 1048576000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

```bash
lsblk
```

```
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda       8:0    0   500G  0 disk /run/media/system/Volume
vda     252:0    0   160G  0 disk 
├─vda1  252:1    0 159.9G  0 part /
├─vda14 252:14   0     4M  0 part 
└─vda15 252:15   0   106M  0 part /boot/efi
```

### make space 

Since disk is full with Docker volume /share, in rstudio.marineenergy.app Terminal:

```bash
du -a /share/data/marinecadastre.gov | sort -n -r | head -n 5
```

```
145854040       /share/data/marinecadastre.gov
11557992        /share/data/marinecadastre.gov/AIS Vessel Tracks 2011
8586948 /share/data/marinecadastre.gov/AIS Vessel Tracks 2015
8581012 /share/data/marinecadastre.gov/AIS Vessel Tracks 2016
8516688 /share/data/marinecadastre.gov/AIS Vessel Tracks 2013
```

```bash
rm -rf /share/data/marinecadastre.gov/AIS\ Vessel\ Tracks\ 201*
df -H
```

Now in SSH terminal, we see enough space:

```
Filesystem      Size  Used Avail Use% Mounted on
udev            4.2G     0  4.2G   0% /dev
tmpfs           837M  824k  836M   1% /run
/dev/vda1       167G  122G   46G  73% /
tmpfs           4.2G     0  4.2G   0% /dev/shm
tmpfs           5.3M     0  5.3M   0% /run/lock
tmpfs           4.2G     0  4.2G   0% /sys/fs/cgroup
/dev/vda15      110M  3.8M  106M   4% /boot/efi
/dev/sda        533G   76M  506G   1% /mnt/volume_sfo2_01
tmpfs           837M     0  837M   0% /run/user/1000
```

### mount


```bash
# mount volume
sudo mount /dev/sda /share

# copy from docker volume /share to host /share
sudo docker cp rstudio-shiny:/share/. /share

# stop all docker containers
docker stop $(docker ps -q)

# rebuild docker
cd ~/mhk-env_server-software
git pull
docker-compose up --build -d

# drop old unused docker volume /share
docker volume prune
```

```
Are you sure you want to continue? [y/N] y
Deleted Volumes:
mhkenvserversoftware_share

Total reclaimed space: 104.4GB
```

Per [Setting Up Persistent Mounting - How to Mount Volumes | DigitalOcean](https://www.digitalocean.com/docs/volumes/how-to/mount/#persistent):


```bash
sudo vi /etc/fstab
```

```
LABEL=cloudimg-rootfs   /        ext4   defaults        0 0
LABEL=UEFI      /boot/efi       vfat    defaults        0 0
/dev/sda /share ext4 defaults,nofail,discard,noatime 0 2
```

```bash
# check that /etc/fstab is parsable and usable
findmnt --verify --verbose
```

## SFTP

[Download Cyberduck](https://cyberduck.io/download/)


server: marineenergy.app

## Setup

```bash
docker exec nginx sh -c "ln -s echo /share/api_out /usr/share/nginx/html/api_out"
docker exec -it nginx bash
```

To get latest for pdf generation:

```r
# If you see an error message like “tlmgr: Remote repository is newer than local (2018 < 2019)”
tinytex::install_tinytex(force=T)

# If an error occurs when compiling a LaTeX to PDF,
tinytex::tlmgr_update()

# if get something like ! LaTeX Error: File `amsmath.sty' not found.
tinytex::parse_install("report_test_1b114955d523.log")
```

Remove TexLive in fafor of TinyTex:

[installing - How to remove everything related to TeX Live for fresh install on Ubuntu? - TeX - LaTeX Stack Exchange](https://tex.stackexchange.com/questions/95483/how-to-remove-everything-related-to-tex-live-for-fresh-install-on-ubuntu)

```bash
sudo apt-get purge texlive*
```

## Add user(s)

```bash
# setup (once) staff to be shared by admin, and default permissions 775
docker exec rstudio gpasswd -a admin staff
docker exec rstudio sh -c "echo 'umask 002' >> /etc/profile"

# override RStudio's default group read only with group read & write
docker exec rstudio sh -c "echo 'Sys.umask('2')\n' >> /usr/local/lib/R/etc/Rprofile.site"
# vs quick fix in Terminal of rstudio.marineenergy.app: sudo chmod -R g+w *

docker exec -it rstudio bash

# Add shiny to staff so has permission to install libraries into `/usr/local/lib/R/site-library` and write files
usermod -aG staff shiny

# set primary group to staff
usermod -g staff shiny
#confirm primary group set to staff
id shiny
# uid=998(shiny) gid=50(staff) groups=50(staff)

user=cdobbelaere
#user=bbest
#user=cgrant
#user=nswanson
pass=secretp@ssHere

# userdel $user; groupdel $user

# add user inside rstudio docker container from host
useradd -m -p $(openssl passwd -crypt $pass) $user
# echo usermod -p "$pass" $user
# usermod -p $(openssl passwd -crypt $pass) $user

# setup (every user) primary group to staff
usermod -aG staff $user
usermod -aG sudo $user
usermod -aG shiny $user
usermod -g staff $user
groups $user

# setup symbolic links in home dir
ln -s /share                /home/$user/share
ln -s /share/data           /home/$user/data
ln -s /share/github         /home/$user/github
ln -s /srv/shinyapps        /home/$user/shiny-apps
ln -s /var/log/shiny-server /home/$user/shiny-logs

# add user to host
exit
sudo adduser $user
sudo usermod -aG sudo $user

# check in container
docker exec -it rstudio-shiny bash
cat /etc/passwd
exit
```

## Stop, start, restart and list services for rstudio and shiny-server

https://wiki.gentoo.org/wiki/S6

Log into terminal:

```bash
ssh bbest@marineenergy.app
```

Then into docker container:

```bash
docker exec -it rstudio bash
```

Get list of s6 processes:

```bash
# list s6 services
ps xf -o pid,ppid,pgrp,euser,args
```

```
PID  PPID  PGRP EUSER    COMMAND
505     0   505 root     bash
745   505   745 root      \_ ps xf -o pid,ppid,pgrp,euser,args
  1     0     1 root     s6-svscan -t0 /var/run/s6/services
 34     1     1 root     s6-supervise s6-fdholderd
211     1     1 root     s6-supervise rstudio
213     1     1 root     s6-supervise shiny-server
214   213   214 root      \_ /opt/shiny-server/ext/node/bin/shiny-server /opt/shiny-server/lib/main.js
226   214   214 root          \_ xtail /var/log/shiny-server/
549   214   549 root          \_ su -s /bin/bash --login -p -- shiny -c cd \/srv\/shiny-server\/sample-apps\/hello && R --no-save --slave -f \/opt\/shiny-server\/R\/SockJSAdapter\.R
551   214   551 root          \_ su -s /bin/bash --login -p -- shiny -c cd \/srv\/shiny-server\/sample-apps\/rmd && R --no-save --slave -f \/opt\/shiny-server\/R\/SockJSAdapter\.R
```

Manage a service:

```bash
cd /var/run/s6/services
# stop
s6-svc -d rstudio
# start
s6-svc -u rstudio
# restart
s6-svc -r rstudio
```

## TODO

Web content:

- Rmd website served by nginx
- **infographics**

Shiny apps:

- **data-uploader**

Install:

- **ERDDAP**: data server
  - similar to [ERDDAP | MBON](http://mbon.marine.usf.edu:8000/erddap/index.html), search "Hyde"
  - [marinebon/erddap-config: ERDDAP config files (setup.xml, datasets.xml)](https://github.com/marinebon/erddap-config)
  
- **Drupal**: content management system
  - [drupal | Docker Hub](https://hub.docker.com/_/drupal/)
  - used by [integratedecosystemassessment.noaa.gov](https://www.integratedecosystemassessment.noaa.gov/)
  - alternative to Wordpress
  
- **CKAN**: data catalog
  - similar mbon.ioos.us
  - used by data.gov
  - federated

- [eduwass/docker-nginx-git](https://github.com/eduwass/docker-nginx-git): Docker Image with Nginx, Git auto-pull and webhooks

- try test migration of volumes in /data/docker on a local machine
- add https
  - "Step 4 — Obtaining SSL Certificates and Credentials" in [How To Install WordPress With Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose#step-4-%E2%80%94-obtaining-ssl-certificates-and-credentials)
  - docker-letsencrypt-nginx-proxy-companion:
  - [Hosting multiple SSL-enabled sites with Docker and Nginx | Serverwise](https://blog.ssdnodes.com/blog/host-multiple-ssl-websites-docker-nginx/)
  - cron job to renew
- add phpmyadmin for web interface to mysql wordpress database
  - [Setting up WordPress with Docker - Containerizers](https://cntnr.io/setting-up-wordpress-with-docker-262571249d50)
