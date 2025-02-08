FROM node:18-alpine

WORKDIR /app

# Copy package files first
COPY ./sample-app/package.json ./
COPY ./sample-app/app.js ./

USER root

EXPOSE 3000

# Add verification steps in CMD
CMD ["/bin/sh", "-c", "ls && echo 'Listing /app contents:' && ls -la /app && echo 'File content:' && cat /app/app.js && chown -R node:node . && su -s /bin/sh node -c 'npm install && node app.js'"]