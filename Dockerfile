# --- STAGE 1: Build Platform ---
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package configurations to leverage layer caching
COPY package*.json ./
RUN npm install

# Copy source code and build frontend production assets
COPY . .
RUN npm run build

# Remove development dependencies completely
RUN npm prune --production


# --- STAGE 2: Ultra Slim Runtime ---
FROM gcr.io/distroless/nodejs18-debian11 AS runner
WORKDIR /app

# Copy only the compiled static assets and clean production node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/index.js ./index.js

EXPOSE 5000

# Distroless images run the binary directly without a shell interpreter
CMD ["index.js"]