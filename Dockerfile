FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files from sample-app directory
COPY sample-app/package*.json ./

# Install dependencie
# Copy the application code from sample-app directory
COPY sample-app/app.js ./
# Create a non-root user and set permissions
USER node

EXPOSE 3000

CMD ["npm", "install"]

CMD ["node", "app.js"]