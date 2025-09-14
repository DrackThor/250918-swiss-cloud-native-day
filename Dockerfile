# Use non-root nginx base image
FROM nginxinc/nginx-unprivileged:stable-alpine

# Copy your static HTML file into the default nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose unprivileged port (default for this image is 8080, not 80)
EXPOSE 8080

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]