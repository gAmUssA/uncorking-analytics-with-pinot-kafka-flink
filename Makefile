# Define the list of directories
DIRS := 01_pinot 02_pinot-kafka 03_pinot-kafka-flink 04_pinot-pulsar 05_pinot-pulsar-flink

# Default target
all: pull_images

# Target to pull images in each directory
pull_images:
	@for dir in $(DIRS); do \
		echo "Pulling Docker images in \033[1m$$dir\033[0m..."; \
		(cd $$dir && docker compose pull); \
		echo "Completed pulling images in \033[1m$$dir\033[0m."; \
	done

# Target to stop all containers in each directory
stop_containers:
	@for dir in $(DIRS); do \
		echo "Stopping all containers in \033[1m$$dir\033[0m..."; \
		(cd $$dir && docker compose down -v); \
		echo "All containers in \033[1m$$dir\033[0m have been stopped and volumes removed."; \
	done

# Target to run the default make task in each directory
run_default_make:
	@for dir in $(DIRS); do \
		echo "Running default make in \033[1m$$dir\033[0m..."; \
		(cd $$dir && make); \
		echo "Completed running make in \033[1m$$dir\033[0m."; \
	done
	
.PHONY: all pull_images stop_containers run_default_make
