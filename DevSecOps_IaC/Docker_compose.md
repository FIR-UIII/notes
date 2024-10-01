# Docker compose
1. Create docker-compose.yml
```
version: '3.8'
services:
  web:
    image: nginx
    volumes:
      - web_data:/var/www/html
  db:
    image: mysql
    volumes:
      - db_data:/var/lib/mysql
volumes:
  web_data:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: /data/db_data
      o: bind
```

2. Основные команды
```
docker compose up -f docker-compose-custom.yml -p custom_project_name up -d #=>Creates and starts your application.
docker compose down #=> Stops and removes your application’s services and networks. By default, it doesn’t remove named volumes unless you use the --volumes or -v flag.
docker compose ps #=> Lists the containers and their current status, including volume-related information.
docker compose config #=> Validates and displays the effective configuration generated from the docker-compose.yml

# Edit container during run
docker-compose stop <container_name> #=> stop container by name
>>> Make changes to the container's configuration or Dockerfile
docker-compose build <service_name> #=> if needed
docker-compose up -d #=> restart
```

### Network
1. Create your net like `docker network create --gateway 10.5.0.1 --subnet 10.5.0.0/16 mynet`
```
version: "3.5"
services:
  nginx:
    networks:
      nw_containers:
        ipv4_address: 10.5.0.2
    <...>
  django:
    networks:
      nw_containers:
        ipv4_address: 10.5.0.3
    <...>
networks:
  nw_containers:
      name: mynet
      external: true
```
