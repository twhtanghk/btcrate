FROM node:6

ENV VER=${VER:-master} \
    REPO=https://github.com/twhtanghk/btcrate \
    APP=/usr/src/app

RUN apt-get update \
&&  apt-get install -y git \
&&  apt-get clean \
&&  rm -rf /var/lib/apt/lists/* \
&&  git clone -b $VER $REPO $APP

WORKDIR $APP

RUN npm install
	
EXPOSE 1337

ENTRYPOINT npm start
