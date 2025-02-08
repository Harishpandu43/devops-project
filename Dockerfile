FROM node:18-alpine AS builder

# Set npm to run in production mode
ENV NODE_ENV=production

# Create a directory for the app and set ownership
WORKDIR /app

# Copy package files first
COPY sample-app/package*.json ./

# Copy the rest of the application
COPY sample-app/ ./

# Install dependencies
RUN npm ci --only=production

# Final stage
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app ./

# Don't run as root
USER node

EXPOSE 3000

CMD ["node", "app.js"]
