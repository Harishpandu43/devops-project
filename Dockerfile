FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
USER node
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node src/ ./src/
COPY --chown=node:node package*.json ./
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "src/app.js"]