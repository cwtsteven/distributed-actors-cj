all: clean build

EXAMPLE_DIR = ./examples

EXAMPLE_TARGET_DIR = ./target/examples

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
	rm -rf $(EXAMPLE_TARGET_DIR)
	mkdir $(EXAMPLE_TARGET_DIR)
	cjc $(EXAMPLE_DIR)/ping-pong.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/ping-pong
	cjc $(EXAMPLE_DIR)/actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/actor-interface
	cjc $(EXAMPLE_DIR)/gc.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/gc
	cjc $(EXAMPLE_DIR)/fjcreate.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/fjcreate
	cjc $(EXAMPLE_DIR)/counter.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/counter
	cjc $(EXAMPLE_DIR)/complete-example.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/complete-example
	cjc $(EXAMPLE_DIR)/dist-actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/dist-actor-interface
	cjc $(EXAMPLE_DIR)/tcp-actor-host.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/tcp-actor-host
	cjc $(EXAMPLE_DIR)/tcp-actor-client.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/tcp-actor-client
	cjc $(EXAMPLE_DIR)/tcp-test-fut-fail.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/tcp-test-fut-fail
	cjc $(EXAMPLE_DIR)/tcp-test-request-fail.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/tcp-test-request-fail
	cjc $(EXAMPLE_DIR)/distributed-actor-example.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/distributed-actor-example
	cjc $(EXAMPLE_DIR)/dummy-actor-system.cj $(OPTIONS) $(IMPORT_ACTORS) $(IMPORT_ACTORS_DISTRIBUTED) -o $(EXAMPLE_TARGET_DIR)/dummy-actor-system
	pushd $(EXAMPLE_DIR)/agent-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/agent-example/target/release/bin/agent_example $(EXAMPLE_TARGET_DIR)/agent_example
	pushd $(EXAMPLE_DIR)/cluster-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.head_server $(EXAMPLE_TARGET_DIR)/cluster_example.head_server && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.worker $(EXAMPLE_TARGET_DIR)/cluster_example.worker && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.entry $(EXAMPLE_TARGET_DIR)/cluster_example.entry

build:
	cjpm build -i

test:
	cjpm test src/tests src/tests/end2end src/macros/internal/tests src/tcp_actor_system/tests

clean:
	pushd $(EXAMPLE_DIR)/agent-example && cjpm clean && popd
	pushd $(EXAMPLE_DIR)/cluster-example && cjpm clean && popd
	cjpm clean