FROM python:3.8-alpine

RUN apk add --no-cache \
    bash \
    build-base \
    libffi-dev \
    openldap-dev \
    openssl-dev \
    postgresql-dev \
    python3-dev \
    xmlsec-dev \
    supervisor \
    git

COPY . /app
WORKDIR /app

RUN pip install -r requirements.txt
RUN pip install python-ldap pysaml2
RUN pip install .

RUN pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=plugins/amqp
RUN pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=integrations/mailer

ENV ALERTA_SVR_CONF_FILE /app/alertad.conf
ENV ALERTA_CONF_FILE /app/alerta.conf
ENV ALERTA_ENDPOINT=http://localhost:5000

RUN mkdir -p /var/log/supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000
ENV FLASK_SKIP_DOTENV=1

# CMD ["alertad", "run", "--host", "0.0.0.0", "--port", "5000"]
CMD ["/usr/bin/supervisord"]