FROM node:18-alpine AS base

FROM base AS deps

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn config set registry 'https://registry.npmmirror.com/'
RUN yarn install

FROM base AS builder

RUN apk update && apk add --no-cache git

ENV OPENAI_API_KEY="sk-LKC2qVuU1YCbUb20A45437Bd8aA845B5931c0444Ee63De82"
ENV BASE_URL="https://api.forcome.com"
 

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN yarn build

FROM base AS runner
WORKDIR /app

RUN apk add proxychains-ng 

ENV OPENAI_API_KEY="sk-LKC2qVuU1YCbUb20A45437Bd8aA845B5931c0444Ee63De82"
ENV BASE_URL="https://api.forcome.com" 
 

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next/server ./.next/server

EXPOSE 3000

CMD ["node", "server.js"]


