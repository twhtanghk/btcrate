FROM node

ENV APP=/usr/src/app
ADD . $APP

WORKDIR $APP

RUN (cd backend && npm install)
	
EXPOSE 3000

CMD (cd backend && npm start)
