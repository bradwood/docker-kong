# Docker-Kong

This is a collection of Docker containers with the appropriate docker images, docker-compose scaffolding and scripts to get [Kong](http://getkong.org), the API management tool, up and running. *_It is NOT for PRODUCTION use!_*

## What is does
It creates 4 docker containers and runs them in your docker environment to enable docker-based testing of Kong. The containers are
  - [bradqwood/ubuntu](https://hub.docker.com/r/bradqwood/ubuntu/) basic ubuntu box with a load of RESTful dev/script tools installed
  - [bradqwood/postgres](https://hub.docker.com/r/bradqwood/postgres/) a basic postgres database needed by Kong
  - [bradqwood/kong](https://hub.docker.com/r/bradqwood/kong/) the Kong box itself
  - [bradqwood/wiremock](https://hub.docker.com/r/bradqwood/wiremock/) a boxed used as a basic RESTful JSON mocking server -- set up as the back-end behind Kong.
  
## To install
You really need to use docker-compose to orchestrate the building and running of each of the 4 images. YMMV if you install each box separately.

### Pre-requisites
- Docker version 1.11.1 or higher
- Docker-compose 1.7.0 or higher

I used the *Docker Toolbox* on Windows 10 to get this working. YMMV on other OSs but it should work with a bit of tweaking. 

### Installation Procecure
```
git clone https://github.com/bradwood/docker-kong.git
cd ./Compose/Kong_test_suite/
```
 - once in `./Compose/Kong_test_suite/` edit `docker-compose.yml` and set the `volumes:` sections to point to your local machine mount points. There are 2:
   - `ubuntu:/root/mnt` - this is so that any kong or other scripts you need to run on the ubuntu box can live outside of the container.
   - `wiremock:/home/wiremock` - this maps to a filesystem that the standalone wiremock system uses to hold your JSON stubs and mapping files.  See the [Wiremock site](http://wiremock.org/running-standalone.html) for more details on this.
 - once you've set the mountpoints, then create the images, install the containers and bring them up ty typing...
```
docker-compose up -d
```
## To use
- Connect to the shell on the ubuntu box
```
docker exec -ti kongtestsuite_ubuntu-dev_1 bash
```
  - at this shell you can `cd /root/mnt` and execute your kong shell scripts from there; and as they're mounted to the host machine, you can edit them in your favourite host-based editor. 
  - set up your JSON mocks in the wiremock mountpoint and save as needed.
  - See under `Mountpoints` for samples of both Kong and JSON stubs

