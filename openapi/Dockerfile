FROM mhart/alpine-node:6.3

# Prepare app directory
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm install 
VOLUME /tmp/specs

ENV NODE_ENV "production"
ENV NODE_PATH "/usr/src/app/node_modules"
# Start the app
ENTRYPOINT [ "/usr/src/app/node_modules/dredd/bin/dredd" ]
