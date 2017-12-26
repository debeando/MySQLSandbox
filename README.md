# MySQL Sandbox in docker

The idea for this project is a to play to change replication topology, make a
failover, recover a master, scale slaves, everything with traffic simulated.

![Orcehstrator screenshot](https://github.com/swapbyt3s/MySQLSandbox/raw/master/assets/orchestrator.png)

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server) V-5.7
- [Orchestrator](https://github.com/github/orchestrator/) V-3.0.3
- [ProxySQL](https://github.com/sysown/proxysql) V-1.4.3
- [Consul](https://www.consul.io/intro/index.html) V-1.0.2

We use a multi-container Docker to defining and running six services for MySQL,
one service for Orchestrator and one for ProxySQL. With six services you have a
possibility to play with slaves, co-master, and intermediate master.

Every container use Centos 7.

## Usage

### First steps

Set environment variable to select MySQL Version, this is `MYSQL_VERSION` a TAG
for image:

```
export MYSQL_VERSION=5.7
```

Version avaible: 5.5, 5.6 and 5.7.

Run docker

```
make build
make up
```

### Configure topology

You have two options to start play. Standard replications with one master and 5
slaves. Or two co-master with 4 slaves. To implement multimaster, first run
`masterslaves.sh` script and then this `multimaster.sh` script.

- Standard replications.

```
./masterslaves.sh
```

- Multimaster:

```
./multimaster.sh
```

You have the next tools to use:

- [orchestrator](http://127.0.0.1:3000/) to see MySQL topology.
- [consul](http://127.0.0.1:8500/ui/)

Enter to MySQL Shell to pass by ProxySQL:

```
make mysql
```

### Run benchmark tool

```
brew install siege
siege -c 2 127.0.0.1
```

### Finish

Stop and remove containers, networks, images, and volumes. Maybe have problem
to start new cluster, try down the old cluster and retry.

```
make down
```
