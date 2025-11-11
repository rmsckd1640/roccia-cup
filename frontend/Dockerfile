FROM nginx:stable-alpine

COPY build/web /usr/share/nginx/html

#nginx 설정 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
