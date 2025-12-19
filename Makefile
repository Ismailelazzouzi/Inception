NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml

DATA_DIR = /home/samael/data

all: up

setup:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

up: setup
	@docker-compose -f $(COMPOSE_FILE) up -d --build

start:
	@docker-compose -f $(COMPOSE_FILE) start

stop:
	@docker-compose -f $(COMPOSE_FILE) stop

down:
	@docker-compose -f $(COMPOSE_FILE) down

re: fclean up

clean: down
	@docker-compose -f $(COMPOSE_FILE) down --rmi all

fclean: down
	@docker-compose -f $(COMPOSE_FILE) down --rmi all --volumes
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_DIR)/mariadb/*
	@sudo rm -rf $(DATA_DIR)/wordpress/*

status:
	@docker-compose -f $(COMPOSE_FILE) ps

logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

.PHONY: all setup up start stop down re clean fclean status logs