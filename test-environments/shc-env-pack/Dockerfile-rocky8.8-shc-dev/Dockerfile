FROM rockylinux:8.8

ENV WORK_HOME /app
ENV TZ=Asia/Seoul

RUN set -eux; \
    ln -Tfs /usr/share/zoneinfo/Asia/Seoul /etc/localtime;

RUN set -eux; \
    sed -i 's/mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/{Rocky-BaseOS.repo,Rocky-AppStream.repo} &&\
    sed -i 's/#baseurl=http:\/\/dl.rockylinux.org/baseurl=http:\/\/ftp.kaist.ac.kr/g' /etc/yum.repos.d/{Rocky-BaseOS.repo,Rocky-AppStream.repo};

RUN set -eux; \
    # add epl ( Extra Packages for Enterprise Linux )
    dnf -y install epel-release &&\ 
    # update and upgrade
    dnf -y update &&\
    # install group of "Development Tools" 
    dnf -y group install "Development Tools" &&\
    # add powertools repo
    dnf install dnf-plugins-core &&\
    dnf config-manager --set-enabled powertools &&\
    # install glibc-static
    dnf -y install glibc-static shc &&\
    dnf -y upgrade --refresh &&\
    dnf clean all &&\
    # create workspace directory `/app`
    mkdir ${WORK_HOME};

WORKDIR ${WORK_HOME}

CMD tail -f /dev/null