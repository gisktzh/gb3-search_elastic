# GB3 Elasticsearch

This is the Elasticsearch configuration for the GB3 search backend. It should be used in conjunction with the GB3
SearchAPI.

## Elasticsearch Deployment

Elasticsearch is deployable with a Docker image. It currently exposes ports *9200* and *9300*, and takes two mounted
volumes - one for the data, and one for the configs.

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

Note that we do not just mount the whole `elasticsearch` folder because that would also back up things such as the JRE
and modules folder. If need be, these could be added later on.

An example invocation looks as follows:

```shell
docker run -p 9200:9200 -p 9300:9300 -e ELASTIC_PASSWORD=mysecurepassword -v es-data:/usr/share/elasticsearch/data -v es-config:/usr/share/elasticsearch/config gb3-es:latest
```

You can then access http://localhost:9200/cluster/health?wait_for_status=yellow&timeout=50s and check the cluster
status.

## Indexing Elasticsearch

The workbenches in the `./FME` directory contain the logic for updating the Elasticsearch indices. The basic idea is the
following:

1. Read all features from the sources and manipulate them if needed.
2. Write all features to a new index, which is postfixed by the `indices_new_postfix` parameter
3. Create an alias on the new index without a postfix
4. Remove the previous alias on the previous index (postfixed by the `indices_old_postfix`) and continue if it fails
5. Remove the previous index from Easticsearch

This leads to very little downtime (i.e. a time where a searchresult might return double values) and also cleans up any
dangling indices. In order to keep track of the indexnames, the postfix should be something that can be readily
identified - a timestamp is a good idea, so a batch script can always take the current timestamp and take yesterday's
timestamp; or you can work with temporary files.

### Parameters

All workbenches take the following parameters:

* `indices_new_postfix`: The new postfix for the index, something which can be automated to be used as old index in the
  next run; e.g. a datetime
* `indices_old_postfix`: The old postfix for the current index
* `geodb_host`: Host of the geodb
* `geodb_port`: Port of the geodb
* `geodb_name`: Name of the geodb
* `geodb_user`: User for accessing the the geodb
* `geodb_password`: Password of `geodb_user`
* `elastic_host`: Host of elasticsearch instance, **including** the port and **excluding** a terminating slash. Note
  that you have to add the port even if you're using non-standard ports, e.g. `https://www.my-elastic-host.ch:443`!
* `elastic_user`: Username for elasticsearch
* `elastic_password`: Pasword for `elastic_user`

These parameters can be added when using the GUI upon running ("Run with parameters") or in batch scripting, e.g.

```
"C:\path_to_fme\FME\fme.exe" C:\path_to_file\gb3-elasticsearch\FME\address_index.fmw
  --indices_new_postfix "20230517"
  --indices_old_postfix "20230516"
  --geodb_host "localhost"
  --geodb_port "1234"
  --geodb_name "my_data_db"
  --geodb_user "db_user"
  --geodb_password "db_password"
  --elastic_host "https://elasticsearch.myserver.ch:443"
  --elastic_user "elastic_user"
  --elastic_password "elastic_password"
```

Note that some workbenches might have additional parameters, e.g. for different sources such as CSV:

* `Places`: This import additionally takes as input parameters the path to the downloaded CSV data of the Swissnames3D
  dataset (https://www.swisstopo.admin.ch/en/geodata/landscape/names3d.html)

### Available indices and aliases and workbenches

The following table represents all available indices, their alias and their source workbench.

| Indexname                     | Aliasname           | Source Workbench    |
|-------------------------------|---------------------|---------------------|
| strkm-`postfix`               | strkm               | special_indexes.fmw |
| beleuchtung-`postfix`         | beleuchtung         | special_indexes.fmw |
| bienenstaende-`postfix`       | bienenstaende       | special_indexes.fmw |
| gvz-`postfix`                 | gvz                 | special_indexes.fmw |
| wasserrechtwww-`postfix`      | wasserrechtwww      | special_indexes.fmw |
| verkehrsmessstellen-`postfix` | verkehrsmessstellen | special_indexes.fmw |
| boje-`postfix`                | boje                | special_indexes.fmw |  
| veloverbindungen-`postfix`    | veloverbindungen    | special_indexes.fmw |
| gewaesserangaben-`postfix`    | gewaesserangaben    | special_indexes.fmw |
| verkehrstechnik-`postfix`     | verkehrstechnik     | special_indexes.fmw |
| schacht-`postfix`             | schacht             | special_indexes.fmw |
| places-`postfix`              | fme-places          | places_index.fmw    |
| addresses-`postfix`           | fme-addresses       | addresses-index.fmw |

## Local installation

1. Create an Image of the Docker container using ```docker build -t gb3-elasticsearch .```
2. Set the password for elasticsearch as an environment variable (ELASTIC_PASSWORD) on the target system (and on the
   target system for the Search API)
2. Run the image locally with ```docker run -d -p 9200:9200 -p 9300:9300 --name gb3-elasticsearch gb3-elasticsearch``` (
   or deploy elsewhere with target port 9200)
3. The URL elasticsearch is listening to needs to be set as an environment variable for the Search API (ELASTIC_URL)
4. Use the FME scripts to create the indexes in elasticsearch. A connection to the PostGIS DB is necessary