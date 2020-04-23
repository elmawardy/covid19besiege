FROM postgres:11
ARG FILE
ARG DBNAME
ENV POSTGRES_PASSWORD 123456
ENV FILE ${FILE}
ENV DBNAME ${DBNAME}
VOLUME /tmp

COPY ${FILE} /tmp/${FILE}

COPY restore_database.sh /docker-entrypoint-initdb.d/restore_database.sh
RUN sed -i 's/\r$//g' /docker-entrypoint-initdb.d/restore_database.sh
RUN chmod 777 /docker-entrypoint-initdb.d/restore_database.sh

EXPOSE 5432
