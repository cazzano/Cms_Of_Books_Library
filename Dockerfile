FROM docker.io/library/nginx:stable
# Create directories for cms and backend
WORKDIR /app
RUN mkdir -p /app/cms /app/backend
# Setup cms files
WORKDIR /app/cms
COPY cms/ ./
COPY cms/ /usr/share/nginx/html/
# Configure nginx to listen on port 4000 instead of default 80
# Added routes for /book, /static, /documents, /pictures, /file_server
RUN echo 'server {\n\
    listen 4000;\n\
    server_name localhost;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html index.htm;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location /book {\n\
        root /usr/share/nginx/html;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location /static {\n\
        root /usr/share/nginx/html;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location /documents {\n\
        root /usr/share/nginx/html;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location /pictures {\n\
        root /usr/share/nginx/html;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location /file_server {\n\
        root /usr/share/nginx/html;\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf
# Expose port 4000
EXPOSE 4000
# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
