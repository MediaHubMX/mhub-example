FROM node:14-alpine AS build
WORKDIR /code
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:14-alpine AS deps
WORKDIR /code
COPY package.json package-lock.json ./
RUN npm ci --production
# Install some caching modules
RUN npm i @mediahubmx/redis-cache @mediahubmx/mongodb-cache

FROM node:14-alpine
EXPOSE 3000
WORKDIR /code
# This will load the modules when the addon is starting
ENV LOAD_MEDIAHUBMX_CACHE_MODULE "@mediahubmx/redis-cache @mediahubmx/mongodb-cache"
COPY --from=build /code/dist ./dist/
COPY --from=deps /code/node_modules ./node_modules/
COPY locales ./locales
CMD node dist
