# MySQL Sandbox in docker

The idea for this project is playing to change replication topology, make a
failover, recover a master, scale slaves, everything with traffic simulated.

![Orcehstrator screenshot](https://github.com/swapbyt3s/MySQLSandbox/raw/master/assets/orchestrator.png)

MySQL Sandbox run in docker and has inside:

- [MySQL Server](https://github.com/mysql/mysql-server) V-5.7
- [Orchestrator](https://github.com/github/orchestrator/) V-3.2.6
- [ProxySQL](https://github.com/sysown/proxysql) (Install latest version 1.4.*)
- [Consul](https://www.consul.io/intro/index.html) V-1.4.2

We use a multi-container Docker to defining and running any services for MySQL,
one service for Orchestrator and one for ProxySQL. With any container of MySQL
you have a possibility to play with slaves, co-master, and intermediate master.

## Limitation:

- Only run MySQL 5.7.
- Only scale MySQL containers.
- Only have high availability for MySQL.
- Only run one container for ProxySQL, Orchestrator and Consul.

## Usage

To simplify the usage, is implemented [Makefile](https://github.com/swapbyt3s/MySQLSandbox/blob/master/Makefile), and you have the all commands
necessary to playing with this sandbox. For example, you can; up, down and scale
containers or enter in the bash. Change topology replication or enter in MySQL
or ProxySQL and more...
