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
./mysql_up_standard.sh
```

Run benchmark tool

```
ab -c 10 -n 100 127.0.0.1/
```
