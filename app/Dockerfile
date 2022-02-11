FROM node:17-alpine

WORKDIR /usr/app

COPY . .

RUN npm install

# run app tests - image build workflow will fail if this fails
RUN npm run test 

EXPOSE 8080
CMD [ "npm", "start" ]