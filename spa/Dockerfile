FROM node:14-alpine as builder
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
# копируем исходники React-приложение в среду сборки
COPY package.json ./
COPY package-lock.json ./
COPY src ./src
COPY public ./public

# устанавливаем NPM-пакеты в соответствии с package-lock.json
RUN npm ci

# мы должны передать этот параметр через --build-arg при запуске сборки
ARG API_URL
# осуществляем сборку приложение на React с использованием параметра
RUN REACT_APP_API_URL=$API_URL npm run build

# продуктивная среда
FROM nginx:stable-alpine
# копируем получившийся в результате сборки статический сайт из "тяжёлого" образа
# на маленький образ с веб-сервером nginx
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]