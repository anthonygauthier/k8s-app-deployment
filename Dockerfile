FROM node:17-alpine

WORKDIR /usr/app

COPY ./app .

RUN npm install
EXPOSE 8080
CMD [ "npm", "start" ]