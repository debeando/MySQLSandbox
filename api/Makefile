.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

deps: ## Install dependencies
	go get -u github.com/go-sql-driver/mysql
	go get -u github.com/gorilla/mux
	go get -u github.com/Pallinder/go-randomdata
	go get -u github.com/tsenart/vegeta

build: ## Build binary
	go build -ldflags "-s -w" -o api main.go

deploy:
	GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o api main.go
