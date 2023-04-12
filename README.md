# Installation
1. Create an Image of the Docker container using ```docker build -t gb3-elasticsearch .```
2. Run the image locally with ```docker run -d -p 9200:9200 -p 9300:9300 --name gb3-elasticsearch gb3-elasticsearch``` (or deploy elsewhere with target port 9200)
3. The URL elasticsearch is listening to needs to be set as an environment variable for the Search API (ELASTIC_URL)
4. Use the FME scripts to create the indexes in elasticsearch. A connection to the PostGIS DB is necessary