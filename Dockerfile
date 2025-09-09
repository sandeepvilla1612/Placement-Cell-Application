# Stage 1: build (including gulp to build assets)
FROM node:18-bullseye AS builder
WORKDIR /app

# copy package files first for caching
COPY package*.json ./

# install deps (including dev for gulp)
RUN npm ci --legacy-peer-deps

# copy source
COPY . .

# build assets (gulp is used in this repo)
# if your gulp command is different, update accordingly
RUN npx gulp || true

# remove dev deps to reduce size
RUN npm prune --production

# Stage 2: runtime
FROM node:18-bullseye-slim
WORKDIR /app

# copy only production files from builder
COPY --from=builder /app /app

ENV NODE_ENV=production
# expose the port your app uses (app reads process.env.PORT - default to 3000)
EXPOSE 3000

CMD ["node", "index.js"]
