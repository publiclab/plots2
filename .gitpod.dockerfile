FROM gitpod/workspace-mysql

COPY config/my.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
