FROM centos:7

ARG USER_ID=82
ARG GROUP_ID=82

RUN yum -y update && yum clean all
RUN yum install -y vsftpd db4-utils db4 epel-release && yum clean all

#inotify-tools supervisor 只能在这个位置安装才成功
RUN yum install -y inotify-tools supervisor && yum clean all

RUN groupadd --system --gid ${GROUP_ID} www-data \
    && adduser --uid ${USER_ID} --gid ${GROUP_ID} --shell /sbin/nologin www-data

# SUPERVISOR
COPY entrypoint.sh /usr/sbin/entrypoint.sh
ADD ./supervisor/supervisord.conf /etc/
ADD ./supervisor/services/* /etc/supervisord.d/

COPY inotify.sh /usr/sbin/
COPY virtual_users.pwd /etc/vsftpd/

RUN chmod +x /usr/sbin/entrypoint.sh && \
    chmod +x /usr/sbin/inotify.sh && \
    mkdir -p /etc/vsftpd/usersconfig/ && \
    mkdir -p /home/vsftpd/ && \
    chown -R www-data:www-data /home/vsftpd/

# VSFTPD
COPY vsftpd.conf /etc/vsftpd/
COPY usersconfig/* /etc/vsftpd/usersconfig/
COPY vsftpd.pam /etc/pam.d/

WORKDIR /home/vsftpd

EXPOSE 20 21

CMD ["/usr/sbin/entrypoint.sh"]
