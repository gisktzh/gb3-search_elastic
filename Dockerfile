FROM elasticsearch:8.17.3

ENV discovery.type=single-node

VOLUME ["/usr/share/elasticsearch/data"]
VOLUME ["/usr/share/elasticsearch/config"]
EXPOSE 9200
EXPOSE 9300

RUN echo "xpack.security.enabled: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

RUN echo "http.cors.enabled: true" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-origin: \"*\"" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-headers: Authorization,X-Requested-With,X-Auth-Token,Content-Type,Content-Length" >> /usr/share/elasticsearch/config/elasticsearch.yml
RUN echo "http.cors.allow-credentials: true" >> /usr/share/elasticsearch/config/elasticsearch.yml

# 'geoip' is not needed and takes a long time to start up (maybe timeout due to proxy?)
RUN echo "ingest.geoip.downloader.enabled: false" >> /usr/share/elasticsearch/config/elasticsearch.yml
