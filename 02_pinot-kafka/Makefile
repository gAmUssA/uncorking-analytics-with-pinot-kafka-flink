GREEN=\033[0;32m
NC=\033[0m # No Color

base: create tables import info

schema:
	docker run \
		-v ${PWD}/table/pinot/movie.sample.json:/sample.json \
		-v ${PWD}/table:/table \
		apachepinot/pinot:latest JsonToPinotSchema \
		-jsonFile /sample.json \
		-pinotSchemaName="movie" \
		-outputDir="/table" \
		-dimensions=""

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
	docker exec kafka kafka-topics.sh \
		--bootstrap-server localhost:9092 \
		--create \
		--topic movie_ratings

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
		-tableConfigFile /tmp/pinot/table/ratings.table.json \
		-schemaFile /tmp/pinot/table/ratings.schema.json \
		-exec

import:
	@docker exec pinot-controller ./bin/pinot-admin.sh \
		LaunchDataIngestionJob \
		-jobSpecFile /tmp/pinot/table/jobspec.yaml

validate:
	@echo "\n🍷 Getting cluster info..."
	@curl -sX GET http://localhost:9000/cluster/info -H 'accept: application/json' | jq .

	@echo "\n🍷 Getting Schemas..."
	@SCHEMAS=$$(curl -sX 'GET' \
      'http://localhost:9000/schemas' \
      -H 'accept: application/json' | jq .); \
	if echo "$$SCHEMAS" | grep -q "movie_ratings"; then \
		echo "Schema 'movie_ratings' found."; \
	else \
		echo "Schema 'movie_ratings' not found."; \
		exit 1; \
	fi; \
	if echo "$$SCHEMAS" | grep -q "movies"; then \
		echo "Schema 'movies' found."; \
	else \
		echo "Schema 'movies' not found."; \
		exit 1; \
	fi

info:     	
	@printf "\n==========================================================\n"
	@printf "🍷 Pinot Query UI:		\033[4mhttp://localhost:9000\033[0m\n"
	@printf "🦊 Redpanda Console:		\033[4mhttp://localhost:9080\033[0m\n"
	@printf "==========================================================\n"

destroy:
	docker compose down -v

