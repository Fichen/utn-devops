FROM node:14-alpine AS builder
WORKDIR /srv/app
COPY . .
RUN npm install
RUN npm run build

FROM node:14-alpine AS dist
WORKDIR /srv/app
COPY --from=builder ./srv/app/dist ./dist
COPY package* ./
RUN npm install --production

EXPOSE 3000
CMD ["node", "dist/index.js"]