FROM node:4.4.4

#RUN mkdir /usr/src/app
#WORKDIR /usr/src/app

# Install dependencies
#COPY package.json package.json
#RUN npm install

ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/

# Prepare app directory
WORKDIR /usr/src/app
COPY . /usr/src/app

ENV NODE_ENV "production"

EXPOSE 8079

# Start the app
CMD [ "npm", "start" ]
