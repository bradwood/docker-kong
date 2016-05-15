# Docker-Kong

This is a collection of Docker Containers with the appropriate docker images, docker-compose scaffolding and scripts to get it up and running.

## What is does
It creates 4 docker containers and runs them in your docker environment to enable docker-based testing. The containers are
  - [bradqwood/ubuntu](https://hub.docker.com/r/bradqwood/ubuntu/) basic ubuntu box with a load of RESTful dev/script tools installed
  - [bradqwood/postgres](https://hub.docker.com/r/bradqwood/postgres/) a basic postgres database needed by Kong
  - [bradqwood/kong](https://hub.docker.com/r/bradqwood/kong/) a kong box
  - [bradqwood/wiremock](https://hub.docker.com/r/bradqwood/wiremock/) a boxed used as a basic RESTful JSON mocking server.
  
## To install
You really need to use docker-compose to to orchestrate the building and running of each of the 4 images. YMMV if you install each box separately.

### Pre-requisites
- Docker version 1.11.1 or higher
- Docker-compose 1.7.0 or higher
- 
I used the Docker toolbox install on Windows 10 to get this working. YMMV on other OSs but it should work with a bit of tweaking. 

### Installation Procecure

```
git clone https://github.com/bradwood/docker-kong.git
cd ./Compose/Kong_test_suite
```
 - once in `./Compose/Kong_test_suite` edit `docker-compose.yml` and set the `volumes:` sections to point to your local machine mount points. There are 2:
   - `ubuntu:/root/mnt` - this is so that any kong or other scripts you need to run on the ubuntu box can live outside of the container.
   - `wiremock:/home/wiremock` - this maps to a filesystem that the standalone wiremock system uses to hold your JSON stubs and mapping files.  See the [Wiremock site](http://wiremock.org/running-standalone.html) for more details on this.
 - then create the images, install the containers and bring them up ty typing...
```
docker-compose up -d
```
## To use
- Get your editor ready and pointing to the two mountpoints referred to earlier.
- Connect to the shell on the ubuntu box
```
docker exec -ti kongtestsuite_ubuntu-dev_1 bash
```
  - at this shell you can `cd /root/mnt` and execute your kong shell scripts from there.
  - See HTML in the right
  - Magic

You can also:
  - Import and save files from GitHub, Dropbox, Google Drive and One Drive
  - Drag and drop files into Dillinger
  - Export documents as Markdown, HTML and PDF

Markdown is a lightweight markup language based on the formatting conventions that people naturally use in email.  As [John Gruber] writes on the [Markdown site][df1]

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text you see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.

### Version
3.2.7

### Tech

Dillinger uses a number of open source projects to work properly:

* [AngularJS] - HTML enhanced for web apps!
* [Ace Editor] - awesome web-based text editor
* [markdown-it] - Markdown parser done right. Fast and easy to extend.
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [Gulp] - the streaming build system
* [keymaster.js] - awesome keyboard handler lib by [@thomasfuchs]
* [jQuery] - duh

And of course Dillinger itself is open source with a [public repository][dill]
 on GitHub.

### Installation

Dillinger requires [Node.js](https://nodejs.org/) v4+ to run.

You need Gulp installed globally:

```sh
$ npm i -g gulp
```

```sh
$ git clone [git-repo-url] dillinger
$ cd dillinger
$ npm i -d
$ NODE_ENV=production node app
```

### Plugins

Dillinger is currently extended with the following plugins

* Dropbox
* Github
* Google Drive
* OneDrive

Readmes, how to use them in your own application can be found here:

* [plugins/dropbox/README.md] [PlDb]
* [plugins/github/README.md] [PlGh]
* [plugins/googledrive/README.md] [PlGd]
* [plugins/onedrive/README.md] [PlOd]

### Development

Want to contribute? Great!

Dillinger uses Gulp + Webpack for fast developing.
Make a change in your file and instantanously see your updates!

Open your favorite Terminal and run these commands.

First Tab:
```sh
$ node app
```

Second Tab:
```sh
$ gulp watch
```

(optional) Third:
```sh
$ karma start
```

### Docker
Dillinger is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 80, so change this within the Dockerfile if necessary. When ready, simply use the Dockerfile to build the image.

```sh
cd dillinger
docker build -t <youruser>/dillinger:latest .
```
This will create the dillinger image and pull in the necessary dependencies. Once done, run the Docker and map the port to whatever you wish on your host. In this example, we simply map port 80 of the host to port 80 of the Docker (or whatever port was exposed in the Dockerfile):

```sh
docker run -d -p 80:80 --restart="always" <youruser>/dillinger:latest
```

Verify the deployment by navigating to your server address in your preferred browser.

### N|Solid and NGINX

More details coming soon.

#### docker-compose.yml

Change the path for the nginx conf mounting path to your full path, not mine!

### Todos

 - Write Tests
 - Rethink Github Save
 - Add Code Comments
 - Add Night Mode

License
----

MIT


**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

  