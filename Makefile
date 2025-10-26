.PHONY: init up down logs ps exec

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
