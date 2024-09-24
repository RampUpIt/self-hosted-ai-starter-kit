FROM n8nio/n8n

# Switch to root user to perform privileged actions
USER root

RUN apk update && apk add \
    curl \
    bash \
    openssl \
    ca-certificates \
    gnupg \
    libc6-compat

# Install additional npm packages (e.g., cheerio)
RUN npm install -g cheerio

# Create a directory for SQLite (if it doesn't exist)
RUN mkdir -p /data/sqlite

# Copy your local SQLite file into the container
COPY db/database.sqlite /data/sqlite/database.sqlite

# Change ownership of the SQLite file to the node user
RUN chown -R node:node /data/sqlite

ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=your_username
ENV N8N_BASIC_AUTH_PASSWORD=your_password
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/data/sqlite/database.sqlite
ENV N8N_EDITOR_BASE_URL=http://localhost:5678/
ENV WEBHOOK_URL=http://localhost:5678/
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

# Switch back to node user for security
USER node
