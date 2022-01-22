# What is this?

This repo aids in the compilation of statically-linked openvpn binaries for easy distribution to Linux, Mac, and Windows systems.

## How To Use:

### Building with Docker:

From inside the code directory:

```sh
$ make
```

### Building with Vagrant:

If docker is not available, Vagrant may be used for the build environment.

From inside the code directory:

```sh
$ vagrant up
$ vagrant ssh -c "make -C /vagrant"
```

### Publishing binaries:

This requires aws client to be installed and configured. The vagrant box already has awscli installed, so you just need to configure it (e.g. with `aws configure`).

```sh
$ make publish
```

 Or with Vagrant

 ```sh
$ vagrant ssh -c "make -C /vagrant publish"
 ```
