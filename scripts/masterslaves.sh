#!/bin/bash
# encoding: UTF-8

# Todo: Query to the consul to get the number of instances.

mysql -h 127.0.0.1 -u sandbox -psandbox -P 3306 -e "
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
" > /dev/null 2>&1
