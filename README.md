# MySQL Sandbox in docker

The idea for this project is a to play to change replication topology, make a
failover, recover a master, everything with traffic simulated.

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server)
- [Orchestrator](https://github.com/github/orchestrator/)
- [ProxySQL](https://github.com/sysown/proxysql)

We use a multi-container Docker to defining and running six services for MySQL,
one service for Orchestrator and one for ProxySQL. With six services you have a
possibility to play with slaves, co-master, and intermediate master.

## Usage

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

Enter to [orchestrator](http://127.0.0.1:3000/web/clusters):

```
http://127.0.0.1:3000/web/clusters
```

Enter into ProxySQL to MySQL Server:

```
mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306
```

Enter into ProxySQL Admin:

```
docker exec -it mysqlsandbox_proxysql_1 mysql -h 127.0.0.1 -u admin -padmin -P 6032
```

Create database and table for test:

```
CREATE DATABASE IF NOT EXISTS sandbox;
USE sandbox;
CREATE TABLE IF NOT EXISTS sandbox.test (
  id INT NOT NULL AUTO_INCREMENT,
  token CHAR(36) NOT NULL,
  value INT NOT NULL,
  unixtimestamp INT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (token)
);
```



```
ab -c 10 -n 100 127.0.0.1/
```

Debuging container

```
docker run --name=orchestrator \
           --detach \
           --tty \
           --rm \
           --publish 3000:3000 \
           --entrypoint=/bin/bash \
           orchestrator

docker exec -it orchestrator /bin/bash
```
