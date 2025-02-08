FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

COPY . .

USER node

EXPOSE 3000

CMD ["node", "app.js"]
