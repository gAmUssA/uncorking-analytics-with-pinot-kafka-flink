GREEN=\033[0;32m
NC=\033[0m # No Color

base: create info tables import

create:
	docker compose build
	docker compose up -d

	@echo "------------------------------------------------"
	@echo "\n⏳ Waiting for Pinot Controller to be ready..."
	@while true; do \
		STATUS_CODE=$$(curl -s -o /dev/null -w '%{http_code}' \
			'http://localhost:9000/health'); \
		if [ "$$STATUS_CODE" -eq 200 ]; then \
			break; \
		fi; \
		sleep 2; \
		echo "Waiting for Pinot Controller..."; \
	done
	@printf "$(GREEN)✔$(NC) 🍷🕺 Pinot Controller is ready!\n"

	@echo "\n⏳ Waiting for Pinot Broker to be ready..."
	@while true; do \
		STATUS_CODE=$$(curl -s -o /dev/null -w '%{http_code}' \
			'http://localhost:8099/health'); \
		if [ "$$STATUS_CODE" -eq 200 ]; then \
			break; \
		fi; \
		sleep 1; \
		echo "Waiting for Pinot Broker..."; \
	done
	@printf "$(GREEN)✔$(NC) 🍷💁 Pinot Broker is ready to receive queries!\n"

	@echo "\n⏳ Waiting for Pinot Server to be ready..."
	@while true; do \
		STATUS_CODE=$$(curl -s -o /dev/null -w '%{http_code}' \
			'http://localhost:8097/health/readiness'); \
		if [ "$$STATUS_CODE" -eq 200 ]; then \
			break; \
		fi; \
		sleep 1; \
		echo "Waiting for Pinot Server..."; \
	done
	@printf "$(GREEN)✔$(NC) 🍷👩‍🔧 Pinot Server is ready to receive requests!\n"

tables:
	@echo "\n 🎥 Creating movies table..."
	@docker exec pinot-controller ./bin/pinot-admin.sh \
		AddTable \
		-tableConfigFile /tmp/pinot/table/movies.table.json \
		-schemaFile /tmp/pinot/table/movies.schema.json \
		-exec

	@echo "\n 🍿 Creating ratings table..."
	@docker exec pinot-controller ./bin/pinot-admin.sh \
		AddTable \
		-tableConfigFile /tmp/pinot/table/ratings.table-pulsar.json \
		-schemaFile /tmp/pinot/table/ratings.schema.json \
		-exec

import:
	@docker exec pinot-controller ./bin/pinot-admin.sh \
		LaunchDataIngestionJob \
		-jobSpecFile /tmp/pinot/table/jobspec.yaml

destroy:
	docker-compose down -v
	docker system prune -f

setup:
	chmod +x setup-pulsar-manager.sh
	./setup-pulsar-manager.sh

info:     	
	@printf "\n==========================================================\n"
	@printf "🍷 Pinot Query UI:		\033[4mhttp://localhost:9000\033[0m\n"
	@printf "🚨 Pulsar Manager:		\033[4mhttp://localhost:9527\033[0m\n"
	@printf "==========================================================\n"
