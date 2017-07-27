# Elastalert RPM Build repository [![Build Status](https://img.shields.io/travis/amine7536/elastalert-rpm/master.svg?style=flat-square)](https://travis-ci.org/amine7536/elastalert-rpm)

Automated Centos7 RPM build of Elastalert [http://elastalert.readthedocs.io/en/latest/](http://elastalert.readthedocs.io/en/latest/) 

## Stack
- Elastalert [http://elastalert.readthedocs.io/en/latest/](http://elastalert.readthedocs.io/en/latest/)
- FPM Packaging tool : [http://fpm.readthedocs.io/en/latest/](http://fpm.readthedocs.io/en/latest/)
- KitchenCI / Inspec : [http://kitchen-ci.org/](http://kitchen-ci.org/)

## Usage

The build script `build.sh` create a python `virtualenv` to install `elastalert` then uses `fpm` to package the entire virtualenv into an RPM. The script works on centos7.

### Build

```bash
$> docker run -v $(pwd):/build -it centos:centos7 /build/build.sh
...

$> rpm -qp --info /build/elastalert-0.1.18-1.el7.x86_64.rpm
Name        : elastalert
Version     : 0.1.18
Release     : 1.el7
Architecture: x86_64
Install Date: (not installed)
Group       : default
Size        : 50901525
License     : Apache 2.0
Signature   : (none)
Source RPM  : elastalert-0.1.18-1.el7.src.rpm
Build Date  : Thu Jul 27 12:06:02 2017
Build Host  : c90b33846cbd
Relocations : /
Packager    : amine.benseddik@gmail.com
Vendor      : @c90b33846cbd
URL         : http://elastalert.readthedocs.io/en/latest
Summary     : ElastAlert - Easy & Flexible Alerting With Elasticsearch.
Description :
ElastAlert - Easy & Flexible Alerting With Elasticsearch.
```

### Configuration

Edit the file `/etc/elastalert/config.yml` :

```yml
rules_folder: /etc/elastalert/rules
es_host: localhost
es_port: 9200
writeback_index: elastalert_status
run_every:
  minutes: 1
buffer_time:
  minutes: 10
```

Don't forget to run for the 1st run : `$> elastalert-create-index`  
[http://elastalert.readthedocs.io/en/latest/running_elastalert.html](http://elastalert.readthedocs.io/en/latest/running_elastalert.html)

### Start

```bash
$> systemctl start elastalert
```

## Run KitchenCI/Inspec test

You will need `ruby`, `bundler` and `docker` installed on you system. A `Vangrantfile` is provided for convinience.
KitchenCI configuration can be found in the file `.kitchen.yml` :

```yml
---
driver:
  name: docker
  use_sudo: false

provisioner:
  name: ansible_playbook
  hosts: test-kitchen
  roles_path: roles
  ansible_verbose: true
  require_ansible_repo: true
  require_ansible_omnibus: false
  require_chef_for_busser: false
  require_ruby_for_busser: false

verifier:
  name: inspec

platforms:
  - name: centos-7.3
    platform: centos
    driver_config:
      image: local/c7-systemd
      run_command: /usr/sbin/init
      port: 22
      volume: 
        - /sys/fs/cgroup:/sys/fs/cgroup:ro
        - <%=ENV['PWD']%>:/build

suites:
  - name: default

```

### Docker with *systemd*

As this package is meant to be used on Centos7 we need to enable *systemd* inside the Docker container used by KitchenCI. This can be done using the dockerfile `systemd.Dockerfile` :

```Dockerfile
FROM centos:centos7

ENV container docker

# Enable Systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
rm -f /usr/lib/tmpfiles.d/systemd-nologin.conf;
VOLUME [ "/sys/fs/cgroup" ]
VOLUME ["/run"]

# Start
CMD ["/usr/sbin/init"]
```

More information can be found on the official Centos7 docker image repos : [https://github.com/docker-library/docs/tree/master/centos](https://github.com/docker-library/docs/tree/master/centos)


### Running the tests

Before running the tests we need to build the base docker image with *systemd* :

```bash
$> docker build --rm -t local/c7-systemd -f systemd.Dockerfile .
```

Then run the tests :

```
$> bundle install
$> bundle exec kitchen test all

...
Profile: tests from {:path=>"/vagrant/test/integration/default/inspec"}
Version: (not specified)
Target:  ssh://kitchen@localhost:32768

  ✔  elastalert-1: Elastalert: Check RPM Installation
     ✔  System Package elastalert should be installed
     ✔  User elastalert should exist
     ✔  User elastalert group should eq "elastalert"
     ✔  User elastalert home should eq "/usr/share/python/elastalert"
     ✔  User elastalert shell should eq "/sbin/nologin"
     ✔  Service elastalert should be installed
     ✔  Service elastalert should not be enabled
     ✔  Service elastalert should not be running
     ✔  File /etc/elastalert/config.yml should exist
     ✔  File /etc/sysconfig/elastalert should exist
     ✔  File /usr/lib/systemd/system/elastalert.service should exist

Profile Summary: 1 successful, 0 failures, 0 skipped
Test Summary: 11 successful, 0 failures, 0 skipped

```

A simple *ansible* playbook is used to install the rpm in kitchen docker image and the `Inspec` test are located under `test/integration/default/inspec`.
