FROM docker.io/library/nginx:stable

# Create directories for cms and backend
WORKDIR /app
RUN mkdir -p /app/cms /app/backend

# Setup cms files
WORKDIR /app/cms
COPY cms/ ./
COPY cms/ /usr/share/nginx/html/

# Configure nginx to listen on port 4000 instead of default 80
RUN echo 'server {\n\
    listen 4000;\n\
    server_name localhost;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html index.htm;\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf

# Expose port 4000
EXPOSE 4000

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
