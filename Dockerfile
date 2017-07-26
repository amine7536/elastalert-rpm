FROM centos:latest

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
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Add kitchen-ci support
RUN yum clean all
RUN yum install -y sudo openssh-server openssh-clients which curl
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''
# RUN systemctl start sshd
RUN if ! getent passwd kitchen; then                 useradd -d /home/kitchen -m -s /bin/bash -p '*' kitchen;               fi
RUN echo "kitchen ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "Defaults !requiretty" >> /etc/sudoers
RUN mkdir -p /home/kitchen/.ssh
RUN chown -R kitchen /home/kitchen/.ssh
RUN chmod 0700 /home/kitchen/.ssh
RUN touch /home/kitchen/.ssh/authorized_keys
RUN chown kitchen /home/kitchen/.ssh/authorized_keys
RUN chmod 0600 /home/kitchen/.ssh/authorized_keys
RUN echo ssh-rsa\ AAAAB3NzaC1yc2EAAAADAQABAAABAQDbzC98YMAdX0ZtNoMc4xmXSIWlJSE0\+KYQHqli45QvSQBpkDzpn7EI8cjpT8iEICbDMkmMufiqtgWAoH8ETz2vO9JiKA2RrSqrsEJCfkh927L5LRNJsSPFzWrz6/SA/CK6mVoiPElZRpHYmiPRKVAoD/p3OmnYGLp5eft0NsH6qMWRnac3PdXh1rFm0q0bExsOHBQvGMwPPZMGYYe927GQmNWAIEV4UPc/zITeMQmW\+pyzdu2J/\+rFkUO3Fb\+E8Si5USka5ZNiOb7IGOL4bRfdGwydvSS1aoycCAaZb0gBp\+IxLXc/B9FI45UQptS7rljuX7cvCNMxEXiRNQ\+HAI89\ kitchen_docker_key >> /home/kitchen/.ssh/authorized_keys

# Start
CMD ["/usr/sbin/init"]