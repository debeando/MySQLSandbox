# MySQL Sandbox in docker

The idea for this project is playing to change replication topology, make a
failover, recover a master, scale slaves, everything with traffic simulated.

![Orcehstrator screenshot](https://github.com/swapbyt3s/MySQLSandbox/raw/master/assets/orchestrator.png)

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server) V-5.7
- [Orchestrator](https://github.com/github/orchestrator/) V-3.0.14
- [ProxySQL](https://github.com/sysown/proxysql) (Install latest version 1.4.*)
- [Consul](https://www.consul.io/intro/index.html) V-1.4.2

We use a multi-container Docker to defining and running any services for MySQL,
one service for Orchestrator and one for ProxySQL. With any container of MySQL
you have a possibility to play with slaves, co-master, and intermediate master.

Every container use Centos 7.

## Limitation:

- Only run MySQL 5.7.
- Only scale MySQL containers.
- Only have high availability for MySQL.
- Only run one container for ProxySQL, Orchestrator and Consul.

## Usage

To simplify the usage, is implemented Makefile, and you have the all commands
necessary to playing with this sandbox. For example, you can; up, down and scale
containers or enter in the bash. Change topology replication or enter in MySQL
or ProxySQL and more...

### First steps

In this step, first build images for each container, next you will remove old images
and then start up the stack:

```
make build
make clear
make up
```

### Scale

Next command scale only MySQL Server to trhee instances:

```
make scale numbers=3
```

### Configure topology

You have two options to start play. Standard replications with one master and 5
slaves. Or two co-master with 4 slaves. To implement multimaster, first run
`masterslaves.sh` script and then this `multimaster.sh` script.

- Standard replications.

Configure classic replication topology Master and Slaves:

```
make masterslaves
```

- Multimaster:

Configure MultiMaster replication topology:

```
make multimaster
```

You have the next tools to use:

- [orchestrator](http://127.0.0.1:3000/) to see and manage MySQL topology.
- [consul](http://127.0.0.1:8500/ui/)

Enter to MySQL Shell to pass by ProxySQL:

```
make mysql
```

### Run benchmark tool

```
brew install siege
siege -c 2 'http://127.0.0.1:8080/user/ POST'
siege -c 2 'http://127.0.0.1:8080/user/random/'
```

## Rotar master without downtime

1. Asegurarse que cada host tenga los mismos datos.
2. El master y candidato a co-master debe tener configurado:
- CHANGE MASTER TO MASTER_USER = 'repl', MASTER_PASSWORD = 'repl';
- CO-Master1:
* SET GLOBAL auto_increment_increment = 2;
- CO-Master2:
* SET GLOBAL auto_increment_increment = 2;
* SET GLOBAL auto_increment_offset = 2;
* SET GLOBAL read_only = OFF;
3. Establecer la replicacion.
4. Revisar la configuracion de cada CO-Master.
5. Revisar en el ProxySQL que esta en el grupo de write y que esta llegando trafico y no hay errores.
SELECT * FROM main.mysql_servers;
SELECT * FROM stats_mysql_connection_pool;
6. Desactivar en el ProxySQL el host deseado, uno de los co-master.
UPDATE main.mysql_servers SET `status` = 'OFFLINE_SOFT' WHERE hostname = '172.16.238.2';
LOAD MYSQL SERVERS TO RUNTIME;
7. Consultar en el ProxySQL que ya no hay trafico entrante en el host marcado como OFFLINE_SOFT.
SELECT * FROM stats_mysql_connection_pool;
8. Retirar la instancia.

```bash
make up
make load_schema
docker exec -it mysqlsandbox_mysql_1 mysql -e "
CHANGE MASTER TO MASTER_USER = 'repl', MASTER_PASSWORD = 'repl';
SET GLOBAL auto_increment_increment = 2;"
make scale numbers=2
docker exec -it mysqlsandbox_mysql_2 mysql -e "
SET GLOBAL auto_increment_increment = 2;
SET GLOBAL auto_increment_offset = 2;
SET GLOBAL read_only = OFF;
"
docker exec -it mysqlsandbox_mysql_1 mysql -e "SHOW VARIABLES LIKE 'auto_increment_%';"
docker exec -it mysqlsandbox_mysql_2 mysql -e "SHOW VARIABLES LIKE 'auto_increment_%';"

# le decimos al orchestator que cree el co-master y le definimos permiso de
# escritura al segundo co-master

docker exec -it mysqlsandbox_proxysql_1 /bin/mysql -h 127.0.0.1 -u admin -padmin -P 6032 -e "SELECT * FROM main.mysql_servers;"

docker exec -it mysqlsandbox_proxysql_1 /bin/mysql -h 127.0.0.1 -u admin -padmin -P 6032 -e "SELECT * FROM stats_mysql_connection_pool;"

make scale numbers=5

make stresstest

docker exec -it mysqlsandbox_proxysql_1 /bin/mysql -h 127.0.0.1 -u admin -padmin -P 6032 -e "
UPDATE main.mysql_servers SET status = 'OFFLINE_SOFT' WHERE hostname = '172.16.238.2';
LOAD MYSQL SERVERS TO RUNTIME;
"

docker stop mysqlsandbox_mysql_1

docker stop mysqlsandbox_mysql_2
```

### Finish

Stop and remove containers, networks, images, and volumes. Maybe have problem
to start new cluster, try down the old cluster and retry.

```
make down
```
