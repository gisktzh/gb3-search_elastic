# GB3 Elasticsearch

This is the Elasticsearch configuration for the GB3 search backend. It should be used in conjunction with the GB3
SearchAPI.

## Elasticsearch Deployment

Elasticsearch is deployable with a Docker image. It currently exposes ports *9200* and *9300*, and takes three mounted
volumes - one for the data, one for the configs and one for logs.

### Build

Currently, no specific build steps are needed, so a basic docker build command should do the trick:

```shell
docker build -t [name-of-image]:[version] .
# example: docker build -t gb3-es:latest .
```

### Run

The image can be run using `docker run`. It requires the following environment variables to be set:

* `ELASTIC_PASSWORD`: The password needed to access Elasticsearch

* An option is to specifiy these variables directly in the docker run command (using the `-e` flag).

Port mappings for `9200` and `9300` should be added, and the volumes to be mounted are:

* `/usr/share/elasticsearch/data`: The data folder where indices are stored
* `/usr/share/elasticsearch/config`: The config folder where configurations such as the keystore are stored
* `/usr/share/elasticsearch/logs`: The logs folder where elasticsearch logs are stored 

Note that we do not just mount the whole `elasticsearch` folder because that would also back up things such as the JRE
and modules folder. If need be, these could be added later on.

An example invocation looks as follows:

```shell
docker run -p 9200:9200 -p 9300:9300 -e ELASTIC_PASSWORD=mysecurepassword -v es-data:/usr/share/elasticsearch/data -v es-config:/usr/share/elasticsearch/config -v es-logs:/usr/share/elasticsearch/logs gb3-es:latest
```

You can then access http://localhost:9200/_cluster/health?wait_for_status=yellow&timeout=50s and check the cluster
status.

### Docker Compose

Alternatively `docker compose` can be used to build and push the image to the internal docker registry:

```shell
docker compose -f docker-compose.ktzh.yml build
docker compose -f docker-compose.ktzh.yml push
```

To deploy the image `ELASTIC_PASSWORD` should be set as an environment variable or in a `.env` file in the target environment. It also requires the three volumes to be set up on the target beforehand:

```shell
docker volume create es-data
docker volume create es-config
docker volume create es-logs
```

Pull and run the the latest build of the image:

```shell
docker compose -f docker-compose.ktzh.yml up -d --pull always
```

## Local installation

1. Create an Image of the Docker container using ```docker build -t gb3-elasticsearch .```
2. Set the password for elasticsearch as an environment variable (ELASTIC_PASSWORD) on the target system (and on the
   target system for the Search API)
2. Run the image locally with ```docker run -d -p 9200:9200 -p 9300:9300 -v elasticsearch-logs:/usr/share/elasticsearch/logs --name gb3-elasticsearch gb3-elasticsearch``` (
   or deploy elsewhere with target port 9200)
3. The URL elasticsearch is listening to needs to be set as an environment variable for the Search API (ELASTIC_URL)