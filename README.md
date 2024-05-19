### Final Project for Otus DevOps Courses (23.11.2023)
### App For Kubernetes Deploy 
___
#### 1. Описание приложения

Приложение состоит из двух частей:


Single Page Application (SPA) — статический сайт на React который получает и изменяет данные, отправляя AJAX-запросы к сервису API.

API — веб сервис, который предоставляет данные о "записавшихся" пользователях и может добавлять новые данные. API записывает данные, которые должны надёжно храниться, в файл. Для хранилища данных используется kubernetes persistent volume.

#### 2. Требования к сборке и разворачиванию приложения

Для разворачивания: Docker Engine, Kubernetes Cluster (kubectl, helm), YC, Git

Для сборки: Node.js, React, Bash

#### 3. Запуск приложения локально

Запуск API:

```console
cd api
node server.js
```

Запуск SPA:

```console
cd spa

### Устанавливаем пакеты npm, указанные в package-lock.json
npm ci

### SPA была создана при помощи create-react-app. Поэтому запустим его при помощи разработческого сервера из react-scripts:
npm run start
```

SPA доступен по адресу: http://localhost:3000/

При нажатии кнопки Log Me!. будет отправлен AJAX-запрос по адресу http://localhost:3000/log и данные User Agent текущего пользователя
будут сохранены в файл ./data/log. Новые данные будут отображены на странице под кнопкой.

Подготовить статический сайт для размещения на продуктиве можно командой:

```console
npm run build
```

#### 4. Докирезация приложения

Dockerfile для сборки образов контенеров лежат в папках ./api и ./spa соответственно.
Для локального запуска приложения в контенерах необходимо:

```console
### Собираем образ API:
docker build api/ -t gitlab-api
### Запускаем контейнер API:
docker run --publish 4000:4000 -d gitlab-api

### Собираем образ SPA:
docker build spa/  --build-arg API_URL=http://localhost:4000 -t  gitlab-spa
### Запускаем контейнер SPA:
docker run -it --publish 80:80 gitlab-spa
```

#### 5. Разворачивание контейнеров в kubernetes

Манифесты для разворачивания приложения в кластере kubernetes находятся в папке ./k8s
Для деплоя необходим kubectl и релевантное подключение к кластеру kubernetes.

Для корректного доступа к интерфейсу необходимо знать IP адрес ингресс контроллера. Адрес нужено поменять в манифесте ingress.yml

```console
---
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: gitlab-ingress
  namespace: default
  labels:
    project: gitlab
spec:
  ingressClassName: nginx
  rules:
    - host: app.{INGRESS_IP}.nip.io
      http:
        paths:
          - path: /log
            pathType: ImplementationSpecific
            backend:
              service:
                name: gitlab-api
                port:
                  number: 80
  defaultBackend:
    service:
      name: gitlab-spa
      port:
        number: 80
```

Для деплоя необходимо:

```console
### Дплоймент и сервис API
kubectl apply -f k8s/api-deployment.yml 
### Дплоймент и сервис SPA
kubectl apply -f k8s/spa-deployment.yml
### Ingress controller
kubectl apply -f k8s/ingress.yml
### Volume Persistence Claim
kubectl apply -f k8s/volume.yml
```

#### 6. Описание пайплайна

Файл .gitlab-ci.yml находится в корне репозитория.

Stages пайплайна:
- build. Собираем контейнеры приложения и пушим их в докер хаб.
- test. Разворачиваем контейнеры локально, тестируем доступность интерфейсов приложения (скрипт scripts/test_http.sh)
- deploy. Мануально разворачиваем контейнеры в кластере kubernetes.
- clean. Мануально удаляем приложение из кластера kubernetes и удаляем локальные контейнеры (скрипт scripts/delete_docker_images.sh)

Описание переменных:
VERSION_TAG: тег для собираемых контейнеров
APP_API_URL: переменная необходимая для сборки контейнера API, http адрес приложения (default: http://{INGRESS_IP}.nip.io)
TEST_URL: IP адрес хоста локальной сборки docker контейнеров
___