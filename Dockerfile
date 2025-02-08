FROM node:18-alpine

# Add necessary system packages
RUN apk add --no-cache dumb-init

# Create app directory and set permissions
WORKDIR /app

# Set ownership to node user
RUN chown -R node:node /app

# Switch to node user for npm install
USER node

# Copy package files from sample-app directory with correct ownership
COPY --chown=node:node sample-app/package*.json ./

# Install dependencies as node user
RUN npm install

# Copy the application code from sample-app directory with correct ownership
COPY --chown=node:node sample-app/ ./

EXPOSE 3000

# Use dumb-init as entrypoint
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "app.js"]
