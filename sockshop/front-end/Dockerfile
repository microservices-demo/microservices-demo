FROM mhart/alpine-node:6.3

ADD package.json /tmp/package.json
RUN cd /tmp && npm install
RUN mkdir -p /usr/src/app && cp -a /tmp/node_modules /usr/src/app/

# Prepare app directory
WORKDIR /usr/src/app
COPY . /usr/src/app

ENV NODE_ENV "production"

# Start the app
CMD [ "npm", "start" ]
