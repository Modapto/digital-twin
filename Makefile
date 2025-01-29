.PHONY: all clean docker publish

DIR_FAAAST = FAAAST-Service
DIR_SMT_SIMULATION_PROCESSOR = faaast-smt-simulation-processor
DIR_TARGET = target
DOCKER_IMAGE_NAME = modapto/digital-twin
DOCKER_TAG = latest
DOCKER_REGISTRY = ghcr.io

all: build

build:
	@echo "Building FAAAST-Service..."; \
	mvn -f $(DIR_FAAAST)/pom.xml install -DskipTests=true; \
	VERSION_FAAAST=$$(mvn -f $(DIR_FAAAST)/pom.xml help:evaluate -Dexpression=project.version -q -DforceStdout); \
	echo "FAAAST version: $$VERSION_FAAAST"; \
	echo "Creating target directory: $$DIR_TARGET"; \
	mkdir -p $(DIR_TARGET); \
	cp $(DIR_FAAAST)/starter/target/starter-$$VERSION_FAAAST.jar $(DIR_TARGET)/starter.jar; \
	echo "Updating dependency to FAAAST Service in SMT Simulation Processor to current FAAAST version..."; \
	mvn -f $(DIR_SMT_SIMULATION_PROCESSOR)/pom.xml versions:set-property -DgenerateBackupPoms=false -Dproperty=faaast-service.version -DnewVersion=$$VERSION_FAAAST; \
	
	@echo "Building faaast-smt-simulation-processor..."; \
	mvn -f $(DIR_SMT_SIMULATION_PROCESSOR)/pom.xml install package; \
	VERSION_SMT_SIMULATION_PROCESSOR=$$(mvn -f $(DIR_SMT_SIMULATION_PROCESSOR)/pom.xml help:evaluate -Dexpression=project.version -q -DforceStdout); \
	echo "Current SMT Simulation Processor version is: $$VERSION_SMT_SIMULATION_PROCESSOR"; \
	cp $(DIR_SMT_SIMULATION_PROCESSOR)/target/smt-simulation-$$VERSION_SMT_SIMULATION_PROCESSOR.jar $(DIR_TARGET)/smt-simulation-processor.jar

docker:
	@echo "Building Docker image..."; \
	docker build -t $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) .

publish:
	@echo "Publishing Docker image..."
	docker login $(DOCKER_REGISTRY); \
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

clean:
	@echo "Cleaning FAAAST-Service..."
	cd $(DIR_FAAAST) && mvn clean
	
	@echo "Cleaning faaast-smt-simulation-processor..."
	cd $(DIR_SMT_SIMULATION_PROCESSOR) && mvn clean
	
	@echo "Cleaning target directory..."
	rm -rf $(DIR_TARGET)
	
	@echo "Cleaning up local images..."
	@if docker image inspect $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG) > /dev/null 2>&1; then \
		docker rmi --force $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG); \
	else \
		echo "Image does not exist."; \
	fi