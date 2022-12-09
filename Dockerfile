FROM node:18.12.1 as source

WORKDIR /src

RUN git clone https://github.com/supabase/storage-api.git .

RUN git checkout tags/v0.26.0 -b v0.26.0

FROM node:18.12.1 as build

WORKDIR /src

COPY --from=source /src/package*.json ./

RUN npm ci --no-progress

COPY --from=source /src ./

RUN npm run build

FROM node:18.12.1 as deps

WORKDIR /src

COPY --from=build /src/package*.json ./

RUN npm ci --omit=dev

FROM node:18.12.1

WORKDIR /app

COPY --from=build /src/package.json ./

COPY --from=deps /src/node_modules node_modules

COPY --from=build /src/migrations migrations

COPY --from=build /src/dist dist

EXPOSE 5000

CMD ["node", "dist/server.js"]