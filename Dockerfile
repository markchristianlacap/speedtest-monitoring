FROM nginx:alpine

# Speedtest CLI version
ARG SPEEDTEST_VERSION=1.2.0

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    bc \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Install Speedtest CLI from official binary
RUN curl -fsSL https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-x86_64.tgz -o speedtest.tgz \
    && tar -xzf speedtest.tgz -C /usr/local/bin speedtest speedtest.5 \
    && rm speedtest.tgz \
    && chmod +x /usr/local/bin/speedtest

# Create speedtest directory
RUN mkdir -p /usr/share/nginx/html/speedtest

# Copy application files
COPY index.html /usr/share/nginx/html/speedtest/
COPY config.json /usr/share/nginx/html/speedtest/
COPY cronjob.sh /usr/local/bin/speedtest-cron.sh

# Update config to use correct path
RUN sed -i 's|/var/www/html/speedtest|/usr/share/nginx/html/speedtest|g' /usr/share/nginx/html/speedtest/config.json

# Initialize results file
RUN echo "[]" > /usr/share/nginx/html/speedtest/results.json \
    && chmod 666 /usr/share/nginx/html/speedtest/results.json

# Make script executable
RUN chmod +x /usr/local/bin/speedtest-cron.sh

# Set up cron job (runs every hour)
RUN echo "0 * * * * /usr/local/bin/speedtest-cron.sh >> /var/log/speedtest.log 2>&1" > /etc/crontabs/root

# Create startup script
RUN echo '#!/bin/bash' > /docker-entrypoint.sh \
    && echo 'crond -b' >> /docker-entrypoint.sh \
    && echo 'nginx -g "daemon off;"' >> /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
