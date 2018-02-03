# MySQL Sandbox in docker

The idea for this project is playing to change replication topology, make a
failover, recover a master, scale slaves, everything with traffic simulated.

![Orcehstrator screenshot](https://github.com/swapbyt3s/MySQLSandbox/raw/master/assets/orchestrator.png)

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server) V-5.7
- [Orchestrator](https://github.com/github/orchestrator/) V-3.0.3
- [ProxySQL](https://github.com/sysown/proxysql) V-1.4.3
- [Consul](https://www.consul.io/intro/index.html) V-1.0.2

We use a multi-container Docker to defining and running any services for MySQL,
one service for Orchestrator and one for ProxySQL. With any container of MySQL
you have a possibility to play with slaves, co-master, and intermediate master.

Every container use Centos 7.

## Limitation:

- Only run MySQL 5.7.
- Only scale MySQL containers.
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
siege -c 2 127.0.0.1
```

### Finish

Stop and remove containers, networks, images, and volumes. Maybe have problem
to start new cluster, try down the old cluster and retry.

```
make down
```
