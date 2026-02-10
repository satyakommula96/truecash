# Multi-stage Dockerfile for Flutter Web Application
# Stage 1: Build Environment
FROM instrumentisto/flutter:3 AS build-env

# Set working directory
WORKDIR /app

# Enable web support
RUN flutter config --enable-web

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build the web application in debug mode (for demo with seed data)
# Note: Flutter 3.38+ doesn't use --web-renderer flag, it's configured in index.html
RUN flutter build web --debug

# Stage 2: Production Environment (Nginx)
FROM nginx:alpine

# Copy built web app from build stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
