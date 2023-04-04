FROM docker.elastic.co/elasticsearch/elasticsearch:8.6.2

ENV discovery.type single-node

VOLUME ["/data"]
WORKDIR /data

RUN echo "xpack.security.enabled: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

RUN echo "http.cors.enabled: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-origin: \"*\"" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-headers: Authorization,X-Requested-With,X-Auth-Token,Content-Type,Content-Length" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-credentials: true" >> /usr/share/elasticsearch/config/elasticsearch.yml