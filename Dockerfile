FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files first
COPY ./sample-app/package.json ./

# Copy application code
COPY ./sample-app/app.js ./

# Switch to non-root user
USER node

EXPOSE 3000

# Set permissions and run the application
CMD ["/bin/sh", "-c", "sudo chown -R node:node /app && ls -la && npm install && node app.js"]
