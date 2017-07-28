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

RUN yum install -y sudo openssh-server openssh-clients which curl epel-release \
    && systemctl enable sshd \
    && yum install -y ansible \
    && yum clean all

# Start
CMD ["/usr/sbin/init"]