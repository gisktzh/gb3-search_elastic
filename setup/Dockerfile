# https://www.docker.elastic.co/
FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

USER root

COPY . /

RUN set -eux; \
	mkdir /state; \
	chown elasticsearch /state; \
	chmod +x /entrypoint.sh

USER elasticsearch:root

ENTRYPOINT ["/entrypoint.sh"]
