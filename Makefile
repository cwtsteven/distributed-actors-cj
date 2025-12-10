all: clean build

EXAMPLE_DIR = ./examples

BASIC_EXAMPLE_DIR = $(EXAMPLE_DIR)/basic-examples

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
	cjc $(BASIC_EXAMPLE_DIR)/ping-pong.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/ping-pong
	cjc $(BASIC_EXAMPLE_DIR)/actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/actor-interface
	cjc $(BASIC_EXAMPLE_DIR)/gc.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/gc
	cjc $(BASIC_EXAMPLE_DIR)/fjcreate.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/fjcreate
	cjc $(BASIC_EXAMPLE_DIR)/counter.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/counter
	cjc $(BASIC_EXAMPLE_DIR)/complete-example.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/complete-example
	pushd $(EXAMPLE_DIR)/distributed-actors-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/distributed-actors-example/target/release/bin/distributed_actors_example.host $(EXAMPLE_TARGET_DIR)/distributed_actors_example.host && cp $(EXAMPLE_DIR)/distributed-actors-example/target/release/bin/distributed_actors_example.client $(EXAMPLE_TARGET_DIR)/distributed_actors_example.client
	pushd $(EXAMPLE_DIR)/serializable-proxy-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/serializable-proxy-example/target/release/bin/serializable_proxy_example.host $(EXAMPLE_TARGET_DIR)/serializable_proxy_example.host && cp $(EXAMPLE_DIR)/serializable-proxy-example/target/release/bin/serializable_proxy_example.client $(EXAMPLE_TARGET_DIR)/serializable_proxy_example.client
	pushd $(EXAMPLE_DIR)/cluster-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.head_server $(EXAMPLE_TARGET_DIR)/cluster_example.head_server && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.worker $(EXAMPLE_TARGET_DIR)/cluster_example.worker && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.entry $(EXAMPLE_TARGET_DIR)/cluster_example.entry
	pushd $(EXAMPLE_DIR)/chat-application-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.server.head $(EXAMPLE_TARGET_DIR)/chat_app_example.server.head && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.server.worker $(EXAMPLE_TARGET_DIR)/chat_app_example.server.worker && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.client $(EXAMPLE_TARGET_DIR)/chat_app_example.client
	pushd $(EXAMPLE_DIR)/agent-example && cjpm clean && cjpm build && popd && cp $(EXAMPLE_DIR)/agent-example/target/release/bin/agent_example $(EXAMPLE_TARGET_DIR)/agent_example

build:
	cjpm build -i

test:
	cjpm test src/tests src/tests/end2end src/macros/internal/tests src/tcp_actor_system/tests

clean:
	pushd $(EXAMPLE_DIR)/distributed-actors-example && cjpm clean && popd
	pushd $(EXAMPLE_DIR)/serializable-proxy-example && cjpm clean && popd
	pushd $(EXAMPLE_DIR)/cluster-example && cjpm clean && popd
	pushd $(EXAMPLE_DIR)/chat-application-example && cjpm clean && popd
	pushd $(EXAMPLE_DIR)/agent-example && cjpm clean && popd
	cjpm clean