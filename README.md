# mhk-env_server-software
server software install using Docker

Contents:
<!--
To update table of contents run: `cat README.md | ./gh-md-toc -`
Uses: https://github.com/ekalinin/github-markdown-toc
-->

* [Server software](#server-software)
* [Shell into server](#shell-into-server)
* [Create Server on DigitalOcean](#create-server)
* [Install Docker](#install-docker)
   * [docker](#docker)
   * [docker-compose](#docker-compose)
* [Build containers](#build-containers)
   * [Test webserver](#test-webserver)
* [Setup domain iea-ne.us](#setup-domain-iea-neus)
* [Run docker-compose](#run-docker-compose)
   * [rstudio-shiny](#rstudio-shiny)
* [Docker maintenance](#docker-maintenance)
   * [Push docker image](#push-docker-image)
   * [Develop on local host](#develop-on-local-host)
   * [Operate on all docker containers](#operate-on-all-docker-containers)
   * [Inspect docker logs](#inspect-docker-logs)
* [TODO](#todo)

## Server software

- Website:<br>
  **www.\***, **mhk-env.us**
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

- Containerized using:
  - [docker](https://docs.docker.com/engine/installation/)
  - [docker-compose](https://docs.docker.com/compose/install/)
  - [nginx-proxy](https://github.com/jwilder/nginx-proxy)

## Shell into server

Secure shell (SSH), eg for Ben Best on Mac Terminal:

```bash
sshpass -f ~/private/password_mhk-env.us ssh bbest@mhk-env.us
```

## Create Server on DigitalOcean

Folks at Integral already handled this, but here's how I handled this for [marinebon/iea-server](https://github.com/marinebon/iea-server)...

Create droplet at https://digitalocean.com with ben@ecoquants.com (Google login):

- Choose an image : Distributions : Marketplace :
  - **Docker** by DigitalOcean VERSION 18.06.1 OS Ubuntu 18.04
- Choose a plan : Standard :
  - _smallest_:
    - **$20 /mo** $0.030 /hour
    - 4 GB / 2 CPUs
    - 80 GB SSD disk
    - 4 TB transfer
  - _small_:
    - **$40 /mo** $0.060 /hour
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
    - **mhk-env.us**

Email recieved with IP and temporary password:

- _mhk-env.us_:

  > Your new Droplet is all set to go! You can access it using the following credentials:
  > 
  > Droplet Name: mhk-env.us
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
sshpass -f ~/private/password_mhk-env.us ssh bbest@mhk-env.us
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

- Bought domain **mhk-env.us** for **$12/yr** with account bdbest@gmail.com.

- DNS matched to server IP `64.225.118.240` to domain **mhk-env.us** via [Google Domains]( https://domains.google.com/m/registrar/iea-ne.us/dns), plus the following subdomains added under **Custom resource records** with:

- Type: **A**, Data:**157.245.189.38** and Name:
  - **@**
  - **gs**
  - **rstudio**
  - **shiny**
- Name: **www**, Type: **CNAME**, Data:**mhk-env.us**

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
echo 'HOST=mhk-env.us' >> .env
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

## mhk-env.us manual post-docker install steps

TODO: fold into `docker-compose.yml`

Log into rstudio.mhk-env.us as admin and use the Terminal to:

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

shiny-logs?

```
cd /usr/share/nginx
mv html html_0
ln -s /share/github/mhk-env.github.io html


/srv/shiny-server




### rstudio-shiny

Haven't figured out how to RUN these commands after user admin is created in rstudio-shiny container.

1. Setup **permissions and shortcuts** for admin in rstudio.

    After logging into rstudio.iea-ne.us, to go to Terminal window and run:

    ```bash
    sudo su -
    ln -s /srv/shiny-server /home/admin/shiny-apps
    ln -s /var/log/shiny-server /home/admin/shiny-logs
    mkdir /srv/github
    ln -s /srv/github /home/admin/github
    
    cd /srv/github
    git clone https://github.com/marinebon/iea-ne_info.git
    git clone https://github.com/marinebon/iea-uploader.git
    
    chown -R admin /srv/shiny-server
    chown -R admin /srv/github
    
    ln -s /usr/share/nginx/html /home/admin/info-html
    chown -R admin /home/admin/info-html
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

Since disk is full with Docker volume /share, in rstudio.mhk-env.us Terminal:

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


```



Had to delete wierd "loop" partition first, per [partitioning - too many primary partitions - Ubuntu - Ask Ubuntu](https://askubuntu.com/questions/932430/too-many-primary-partitions-ubuntu).

```
bbest@mhk-data-ubuntu:~$ sudo parted
(parted) select /dev/sda
Using /dev/sda
(parted) print                                                            
Model: DO Volume (scsi)
Disk /dev/sda: 537GB
Sector size (logical/physical): 512B/512B
Partition Table: loop
Disk Flags: 

Number  Start  End    Size   File system  Flags
 1      0.00B  537GB  537GB  ext4

(parted) rm 1                                                             
Warning: Partition /dev/sda is being used. Are you sure you want to continue?
Yes/No? Yes            
```

Per [How to Create Partitions on DigitalOcean Block Storage Volumes :: DigitalOcean Product Documentation](https://www.digitalocean.com/docs/volumes/how-to/partition/):

```bash
sudo parted /dev/sda
```

```
GNU Parted 3.2
Using /dev/sda
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted)                                                                  
(parted) print                                                            
Model: DO Volume (scsi)
Disk /dev/sda: 537GB
Sector size (logical/physical): 512B/512B
Partition Table: loop
Disk Flags: 

Number  Start  End    Size   File system  Flags
 1      0.00B  537GB  537GB  ext4

(parted) mkpart                                                           
File system type?  [ext2]?                                                
Start? 0%                                                                 
End? 100%  

sudo parted -s /dev/sda mkpart 0% 100%
```

```bash
sudo mkdir /share
sudo mount /dev/sda# /share
```

To mount the drive, enter:
$ sudo mount /dev/sdb1 /media/newhd

sudo mount -o defaults,nofail,discard,noatime /dev/disk/by-id/scsi-example /mnt/example_mount_point


sudo vi /etc/fstab



## shiny app shuffle

in rstudio.iea-demo.us terminal:

```
cd /srv
mkdir -p github/iea-ne_apps
cd /srv/shiny-server/
mv * ../github/iea-ne_apps/.
mv .git ../github/iea-ne_apps/.
mv .gitignore ../github/iea-ne_apps/.
ln -s /srv/github/iea-ne_apps/test /srv/shiny-server/test
cd ../github

ln -s /srv/github/iea-uploader /srv/shiny-server/uploader
```


## erddap quick fix

```bash
git pull

nc_local=./erddap/data/iea-ne/ex-chl-ppd/M_201901-MODISA-NESGRID-CHLOR_A.nc
nc_docker=erddap:/erddapData/iea-ne/ex-chl-ppd/M_201901-MODISA-NESGRID-CHLOR_A.nc
docker exec erddap bash -c "mkdir -p /erddapData/iea-ne/ex-chl-ppd"
docker exec erddap bash -c "mkdir -p /usr/local/tomcat/conf/Catalina/localhost"
docker cp $nc_local $nc_docker

docker exec -it erddap bash -c "cd /usr/local/tomcat/webapps/erddap/WEB-INF && bash GenerateDatasetsXml.sh -verbose"
```
Doh! Still Bad Gateway at http://erddap.iea-demo.us/

```
Parameters for loading M_201901-MODISA-NESGRID-CHLOR_A.nc using:
GenerateDatasetsXml.sh -verbose

- Which EDDType: EDDGridFromNcFiles
- Parent directory: /erddapData/iea-ne/ex-chl-ppd
- File name regex: .*\.*nc
- Full file name of one file: /erddapData/iea-ne/ex-chl-ppd/M_201901-MODISA-NESGRID-CHLOR_A.nc
- ReloadEveryNMinutes: 10
- cacheFromUrl:
^D
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
