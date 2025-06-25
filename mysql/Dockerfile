FROM mysql:8.0

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=doriav2_root_password
ENV MYSQL_DATABASE=doriav2
ENV MYSQL_USER=doriav2_user
ENV MYSQL_PASSWORD=doriav2_password

# Copy MySQL configuration
COPY my.cnf /etc/mysql/conf.d/custom.cnf

# Copy initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Create directory for logs
RUN mkdir -p /var/log/mysql && chown mysql:mysql /var/log/mysql

EXPOSE 3306

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1
