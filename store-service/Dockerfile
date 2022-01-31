FROM node:16.13

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install

COPY . .
EXPOSE 8083

CMD [ "npm", "start" ]