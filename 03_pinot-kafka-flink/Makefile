GREEN=\033[0;32m
NC=\033[0m # No Color

base: create topic tables validate superset-setup info

create:
	docker compose build --no-cache
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

	@echo "\n⏳ Waiting for Kafka to be ready..."
	@while ! nc -z localhost 9092; do \
		sleep 1; \
		echo "Waiting for Kafka..."; \
	done
	@printf "$(GREEN)✔$(NC) 🪲 Kafka is ready!\n"

topic:
	docker exec uncorking-pinot-kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic rated_movies

tables:
	@echo "\n 🎥 🍿Creating Rated Movies table..."
	@docker exec pinot-controller ./bin/pinot-admin.sh \
		AddTable \
		-tableConfigFile /tmp/pinot/table/ratedmovies.table.json \
		-schemaFile /tmp/pinot/table/ratedmovies.schema.json \
		-exec

validate:
	@echo "\n🍷 Getting cluster info..."
	@curl -sX GET http://localhost:9000/cluster/info -H 'accept: application/json'

	@echo "\n🍷 Getting Schemas..."
	@SCHEMAS=$$(curl -sX 'GET' \
      'http://localhost:9000/schemas' \
      -H 'accept: application/json'); \
	if echo "$$SCHEMAS" | grep -q "rated_movies"; then \
		echo "Schema 'rated_movies' found."; \
	else \
		echo "Schema 'rated_movies' not found."; \
		exit 1; \
	fi; \

superset-setup:
	docker exec superset-pinot superset fab create-admin --username admin --firstname Superset --lastname Admin --email admin@superset.com --password admin
	docker exec superset-pinot superset db upgrade  
	docker exec superset-pinot superset init

info:     	
	@printf "\n==========================================================\n"
	@printf "🍷 Pinot Query UI:		\033[4mhttp://localhost:9000\033[0m\n"
	@printf "🦇 Kafka Console (Kafbat):	\033[4mhttp://localhost:9080\033[0m\n"
	@printf "🐿️ Flink Console:		\033[4mhttp://localhost:8081\033[0m\n"
	@printf "📊 Superset Dashboard:		\033[4mhttp://localhost:8088\033[0m\n"
	@printf "==========================================================\n"

destroy:
	docker compose down -v
