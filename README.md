# MySQL Sandbox in docker

The idea for this project is a to play to change replication topology, make a
failover, recover a master, everything with traffic simulated.

![Orcehstrator screenshot](https://github.com/swapbyt3s/MySQLSandbox/raw/master/assets/orchestrator.png)

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server) V-5.7
- [Orchestrator](https://github.com/github/orchestrator/) V-3.0.2
- [ProxySQL](https://github.com/sysown/proxysql) V-1.4.3

We use a multi-container Docker to defining and running six services for MySQL,
one service for Orchestrator and one for ProxySQL. With six services you have a
possibility to play with slaves, co-master, and intermediate master.

## Usage

### First steps

```
docker-compose build
docker-compose up
./start.sh
```

Go to local [orchestrator](http://127.0.0.1:3000/) to see MySQL topology.

Enter to MySQL Shell to pass by ProxySQL:

```
mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306
```

### Run benchmark tool

```
brew install siege
siege -c 2 127.0.0.1
```
