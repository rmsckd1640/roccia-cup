# FROM ghcr.io/cirruslabs/flutter:3.35.7 AS build

# WORKDIR /app
# COPY . .
# RUN flutter pub get
# RUN flutter build web --release

FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html

EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]

