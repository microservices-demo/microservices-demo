FROM mhart/alpine-node:6.3

# Prepare app directory
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm install

ENV NODE_ENV "production"

# Start the app
ENTRYPOINT [ "/usr/src/app/node_modules/dredd/bin/dredd" ]
