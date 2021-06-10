FROM ubuntu:20.04

RUN cp /etc/apt/sources.list /etc/apt/sources.backup.list

# Please comment this line if you are not using Tencent Cloud network
# COPY sources.list /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y cmake gdb vim emacs locales
RUN apt-get install -y python3 curl sudo net-tools git aria2

RUN useradd -m codeserver && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "codeserver ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
RUN locale-gen en_US.UTF-8

ENV LANG=en_US.utf8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN aria2c https://hub.fastgit.org/cdr/code-server/releases/download/v3.10.2/code-server_3.10.2_amd64.deb && \
    dpkg -i code-server_3.10.2_amd64.deb

RUN usermod -s /bin/bash codeserver
RUN chsh -s /bin/bash codeserver
ENV SHELL=/bin/bash 

USER codeserver

# PDF Extension
RUN code-server --install-extension tomoki1207.pdf

# Formatter Extension
RUN code-server --install-extension esbenp.prettier-vscode

# Markdown Extension
RUN code-server --install-extension yzhang.markdown-all-in-one

# Material Theme Extension
RUN code-server --install-extension equinusocio.vsc-material-theme 

USER root

# Python3-pip
RUN apt-get update
RUN apt-get install -y python3-dev python3-pip python3-setuptools

# Fuck Extension
RUN pip3 install thefuck
RUN echo "eval \"\$(thefuck --alias)\" " >> /home/codeserver/.bashrc

RUN chown codeserver -R /home/codeserver/.local/share/

RUN cp /etc/apt/sources.list /etc/apt/sources-tencent.list
RUN mv /etc/apt/sources.backup.list /etc/apt/sources.list
RUN apt-get update

EXPOSE 7777

ENV PASSWORD=codeserver

USER codeserver

CMD [ "code-server", "--bind-addr", "0.0.0.0:7777", "--auth", "password" ]
