.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the containers
	docker-compose build $(name)

up: ## Run all containers
	docker-compose up $(name)

scale: ## Scale MySQL containers
	docker-compose scale mysql=$(numbers)

down: ## Stop all containers
	docker-compose down

ps: ## Show status for all containers
	docker-compose ps

bash: ## Enter bash in specific container, make name=proxysql number=1 bash
	docker exec -it mysqlsandbox_$(name)_$(number) /bin/bash

clear: ## Remove all images with <none> name
	- docker ps -a -q | xargs docker rm
	- docker images | grep "^<none>" | awk '{print $$3}' | xargs docker rmi

console: ## Enter in MySQL console bypass from ProxySQL
	mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306

admin-proxysql: ## Enter in ProxySQL console
	docker exec -it mysqlsandbox_proxysql_1 /bin/mysql -h 127.0.0.1 -u admin -padmin -P 6032

load_schema: ## Load default schema on MySQL
	./scripts/schema.sh

masterslaves: ## Configure classic replication topology Master and Slaves
	./scripts/masterslaves.sh

multimaster: ## Configure MultiMaster replication topology
	./scripts/multimaster.sh

stresstest-post: ## Start stress test with siege tool making HTTP/POST
	siege -c 2 'http://127.0.0.1:8080/user/ POST'

stresstest-get: ## Start stress test with siege tool making HTTP/GET
	siege -c 2 'http://127.0.0.1:8080/user/random/'
