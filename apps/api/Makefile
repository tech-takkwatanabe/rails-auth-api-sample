.PHONY: init up down logs ps exec test

init:
	@docker-compose build

up:
	@docker-compose up -d

down:
	@docker-compose down

logs:
	@docker-compose logs -f api

ps:
	@docker-compose ps

exec:
	@docker-compose exec api bash

test:
	@docker-compose exec api bin/rails test $(file)
