# About

wappcam is a project work of the ["Photonics and Image Processing"
group (University of Applied Science,
Darmstadt)"](http://www.h-da.de/studium/studienangebot/mathematik-und-naturwissenschaften/optotechnik-bildverarbeitung-bsc/nocache/). Its
aim is to create a Lua based camera (web-) server and a HTML +
Javascript based client (GUI). 

# Install on Ubuntu (>=12.04)

The wappcam server requires:

 - Lua (5.1)
 - orbit
 - v4l (video for linux)
 - OpenCV (>=2.2)
 - luacv (patched version, which works with Lua 5.1 see below)
 - cmake

## Standard package installation with apt
```shell
$ sudo apt-get install subversion luarocks libopencv-*-dev cmake
$ sudo luarocks install orbit
```

## luacv patching and building

The luacv package required is a slightly modified version of revision 62 (the last revision working with Lua 5.1). 

### Checkout luacv revision 62
```shell
$ svn co https://luacv.svn.sourceforge.net/svnroot/luacv -r 62
```

### Apply patch for encoding image in memory
```shell
$ cd luacv
$ cp luacv_encode.patch .
$ patch -p0 < luacv_encode.patch
```

### Build luacv
```shell
$ mkdir build
$ cd build
$ cmake ../src/
$ make
```

### Install luacv
```shell
$ sudo cp luacv.so.0.2.0 /usr/local/lib/lua/5.1/luacv.so
```

# Running the server
Starts the wappcam webserver, listening on port 8080
```shell
orbit wappcam.lua
```
Connect with a browser on, e.g. http://localhost:8080



