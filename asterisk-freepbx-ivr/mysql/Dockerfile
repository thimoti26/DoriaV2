FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_DATABASE=freepbx
ENV MYSQL_USER=freepbx_user
ENV MYSQL_PASSWORD=freepbx_password

COPY init/init.sql /docker-entrypoint-initdb.d/