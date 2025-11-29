# ----------------------------------------------------
# Phase 1: Build Strapi (Admin panel + server)
# ----------------------------------------------------
FROM node:20-alpine AS builder

# Install build dependencies for native modules (better-sqlite3)
RUN apk add --no-cache python3 make g++ 

# Create app folder
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL deps (including devDeps for building admin panel)
RUN npm install

# Copy the rest of the app
COPY . .

# Build the admin panel
RUN NODE_ENV=production npm run build


# ----------------------------------------------------
# Phase 2: Production Image
# ----------------------------------------------------
FROM node:20-alpine

# Install runtime dependencies for native modules
RUN apk add --no-cache python3 make g++

WORKDIR /app

ENV NODE_ENV=production

# Copy everything from builder (includes node_modules with built admin)
COPY --from=builder /app ./

# Remove dev dependencies to reduce image size
RUN npm prune --omit=dev

EXPOSE 1337

CMD ["npm", "run", "start"]
