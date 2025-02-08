FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files first
COPY ./sample-app/package.json ./

# Copy application code
COPY ./sample-app/app.js ./

# Set ownership of the app directory
RUN chown -R node:node /app

# Switch to non-root user
USER node

EXPOSE 3000

# Run npm install and then start the application
CMD ["/bin/sh", "-c", "ls -la && npm install && node app.js"]