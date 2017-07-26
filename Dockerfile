FROM centos:centos7

# System Deps
RUN yum -y install ruby ruby-devel gcc make rpm-build epel-release \
        && yum -y install python-pip  python-virtualenv

# Python Env
RUN pip install --upgrade pip \
        && pip install "setuptools>=11.3" \
        && pip install virtualenv-tools \
        && pip install "elasticsearch>=5.0.0" \
        && pip install "urllib3==1.21.1" \
        && gem install fpm

# Volumes
RUN mkdir /build
VOLUME /build
WORKDIR /build

# Build
CMD ["/build/build.sh"]
