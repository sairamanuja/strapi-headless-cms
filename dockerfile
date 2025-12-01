FROM node:20-alpine AS builder

RUN apk add --no-cache python3 make g++ 

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN NODE_ENV=production npm run build

FROM node:20-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app ./

RUN npm prune --omit=dev

EXPOSE 1337

CMD ["npm", "run", "start"]