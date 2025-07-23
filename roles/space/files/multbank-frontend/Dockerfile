# syntax=docker/dockerfile:1

FROM node:22-alpine AS builder
WORKDIR /app

# Instala dependências e gera build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Etapa final: serve os arquivos estáticos
FROM node:22-alpine AS prod
WORKDIR /app

# Instala o servidor estático
RUN npm install -g serve

# Copia os arquivos gerados no build
COPY --from=builder /app/dist ./dist

EXPOSE 5173
CMD ["serve", "-s", "dist", "-l", "5173"]
