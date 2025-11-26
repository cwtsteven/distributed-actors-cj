all: clean build example

EXAMPLE_DIR = ./examples

TARGET_DIR = ./target/examples

ARCH := $(shell uname -m)

OS := $(shell uname -s)

ifeq ($(OS),Linux)
    OS_NAME := linux
else ifeq ($(OS),Darwin)
    OS_NAME := darwin
else ifeq ($(OS),Windows_NT)
    OS_NAME := windows
else
    OS_NAME := unknown
endif

OPTIONS = -g
IMPORT_ACTORS = --import-path ./target/release/actors -L./target/release/actors -lactors
IMPORT_ACTORS_DISTRIBUTED = -lactors.distributed -lactors.tcp_actor_system -lactors.distributed.mcp

example:
	rm -rf $(TARGET_DIR)
	mkdir $(TARGET_DIR)
	cjc $(EXAMPLE_DIR)/ping-pong.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/ping-pong
	cjc $(EXAMPLE_DIR)/actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/actor-interface
	cjc $(EXAMPLE_DIR)/gc.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/gc
	cjc $(EXAMPLE_DIR)/fjcreate.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/fjcreate
	cjc $(EXAMPLE_DIR)/counter.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/counter
	cjc $(EXAMPLE_DIR)/complete-example.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(TARGET_DIR)/complete-example
	cjc $(EXAMPLE_DIR)/dist-actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(TARGET_DIR)/dist-actor-interface
	cjc $(EXAMPLE_DIR)/tcp-actor-host.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(TARGET_DIR)/tcp-actor-host
	cjc $(EXAMPLE_DIR)/tcp-actor-client.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(TARGET_DIR)/tcp-actor-client
	cjc $(EXAMPLE_DIR)/distributed-actor-example.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(TARGET_DIR)/distributed-actor-example
	cjc $(EXAMPLE_DIR)/dummy-actor-system.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(TARGET_DIR)/dummy-actor-system
	pushd $(EXAMPLE_DIR)/agent-example && cjpm build && popd && cp $(EXAMPLE_DIR)/agent-example/target/release/bin/agent_example $(TARGET_DIR)/agent_example

build:
	cjpm build -i

test:
	cjpm test src/tests src/tests/end2end src/macros/internal/tests src/tcp_actor_system/tests

clean:
	pushd $(EXAMPLE_DIR)/agent-example && cjpm clean && popd
	cjpm clean