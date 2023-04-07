# Use a lightweight base image
FROM nginx:alpine

# Copy static files to the web root directory
COPY ./src /usr/share/nginx/html

# Expose port for incoming HTTP traffic
EXPOSE 5500