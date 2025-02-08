# Build stage
FROM node:18-alpine AS builder

WORKDIR /build

# Copy package files
COPY sample-app/package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY sample-app/ ./

# Production stage
FROM node:18-alpine

# Add dumb-init
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built application from builder stage
COPY --from=builder --chown=appuser:appgroup /build ./

# Use non-root user
USER appuser

EXPOSE 3000

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "app.js"]
