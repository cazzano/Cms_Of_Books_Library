FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install supervisor, Python, and pip
RUN apt update && apt upgrade -y
RUN apt install python3 -y

# Create directories for frontend and backend
WORKDIR /app
RUN mkdir -p /app/cms /app/backend

# Setup frontend
WORKDIR /app/cms
COPY cms/ ./
# Uncomment these if you need to build a Node.js frontend
# RUN apt install -y nodejs npm
# COPY frontend/package*.json ./
# RUN npm install
# RUN npm run build

# Setup backend
#WORKDIR /app/backend
# Make sure requirements.txt exists in your backend directory
#COPY backend/requirements.txt ./
# Use pip3 with -r flag to specify requirements file
#RUN pip3 install --no-cache-dir -r requirements.txt
#COPY backend/ ./

# Configure supervisor
# Directory should already exist with Ubuntu's supervisor package
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose necessary ports
EXPOSE 4000

# Start supervisor as the main process
CMD ["python3","-m", "http.server", "4000", "--bind", "0.0.0.0"]
