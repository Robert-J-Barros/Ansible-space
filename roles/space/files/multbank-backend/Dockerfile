# Etapa de build
FROM node:22-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . ./
RUN npm run build

# Etapa final: produção
FROM node:22-alpine AS prod
WORKDIR /app

# Instala o PM2
RUN npm install -g pm2

# Copia apenas o necessário da etapa de build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/ecosystem.config.js ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.env ./
# Instala apenas as dependências de produção
RUN npm install --omit=dev

EXPOSE 3000

CMD ["pm2-runtime", "ecosystem.config.js"]
