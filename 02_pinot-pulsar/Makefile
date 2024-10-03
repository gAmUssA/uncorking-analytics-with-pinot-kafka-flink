GREEN=\033[0;32m
NC=\033[0m # No Color

base: create info

create:
	docker compose build --no-cache
	docker compose up -d

destroy:
	docker compose down -v

info:     	
	@printf "\n==========================================================\n"
	@printf "🍷 Pinot Query UI:		\033[4mhttp://localhost:9000\033[0m\n"
	@printf "🚨 Pulsar Manager:		\033[4mhttp://localhost:9527\033[0m\n"
	@printf "==========================================================\n"
