# MySQL Sandbox in docker

First steps

```
docker-compose build
docker-compose up
```

Add first Master into orchestrator:

```
docker exec -it mysqlsandbox_orchestrator_1 /usr/bin/orchestrator -c discover -i 172.20.1.201
```

Create a replication between MySQL Servers:

```
docker exec -it mysqlsandbox_db2_1 /root/replicate.sh
docker exec -it mysqlsandbox_db3_1 /root/replicate.sh
docker exec -it mysqlsandbox_db4_1 /root/replicate.sh
docker exec -it mysqlsandbox_db5_1 /root/replicate.sh
docker exec -it mysqlsandbox_db6_1 /root/replicate.sh
```
