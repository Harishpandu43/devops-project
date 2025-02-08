FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files from sample-app directory
COPY sample-app/package*.json ./

# Install dependencies
RUN npm install

# Copy the application code from sample-app directory
COPY sample-app/ ./
# Create a non-root user and set permissions
USER node

EXPOSE 3000

CMD ["node", "app.js"]