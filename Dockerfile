# Estágio 1: Construção (Build)
FROM node:20-alpine AS build
# Instala dependências nativas necessárias para o Sharp / Vips / node-gyp
RUN apk update && apk add --no-cache build-base gcc autoconf automake libtool zlib-dev libpng-dev nasm bash vips-dev
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/
COPY package.json package-lock.json ./
RUN npm ci --only=production
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/app
COPY . .
# Roda o build do Strapi (e compila o TypeScript)
RUN npm run build

# Estágio 2: Execução (Runtime - Imagem Final Leve)
FROM node:20-alpine
RUN apk add --no-cache vips-dev
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/
COPY --from=build /opt/node_modules ./node_modules
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/app
COPY --from=build /opt/app ./

EXPOSE 1337
CMD ["npm", "run", "start"]