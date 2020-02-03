FROM mariadb:10.3

COPY autoconfig.sh /autoconfig.sh
RUN chmod +x /autoconfig.sh
ENTRYPOINT ["/autoconfig.sh"]

CMD ["mysqld"]
