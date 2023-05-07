FROM ubuntu:22.04

RUN apt update && apt upgrade \
  && apt install -y build-essential curl

SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN source /root/.bashrc \
  && nvm install --lts \
  && npm install pm2 -g

COPY . /app
WORKDIR /app

RUN source /root/.bashrc \
  && make install
