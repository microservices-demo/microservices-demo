FROM node:4.4.4

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# Install dependencies
COPY package.json package.json
RUN npm install

# Prepare app directory
COPY . /usr/src/app

EXPOSE 8079

# Start the app
CMD [ "npm", "start" ]
