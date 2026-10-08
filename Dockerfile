FROM node:24-alpine AS build

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@12.10.1 --activate

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY nest-cli.json tsconfig*.json ./
COPY src ./src
RUN pnpm run build

FROM node:24-alpine AS runtime

ARG APP_VERSION=3.0.0
ENV NODE_ENV=production
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@12.10.1 --activate
LABEL org.opencontainers.image.version="${APP_VERSION}"

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --prod --frozen-lockfile && pnpm store prune
COPY --from=build --chown=node:node /app/dist ./dist

USER node
EXPOSE 3000

CMD ["node", "dist/main.js"]
