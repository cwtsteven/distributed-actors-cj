all: clean build

CJC = cjc
CJPM = cjpm

EXAMPLE_DIR = ./examples
BASIC_EXAMPLE_DIR = $(EXAMPLE_DIR)/basic-examples
EXAMPLE_TARGET_DIR = ./target/examples
OPTIONS = -g
IMPORT_ACTORS = --import-path ./target/release/actors --import-path $(CANGJIE_STDX_PATH) -L./target/release/actors -L$(CANGJIE_STDX_PATH) -lactors

OS := $(shell uname -s)
ARCH := $(shell uname -m)

ifeq ($(ARCH),arm64)
	CJ_ARCH := aarch64
else ifeq ($(ARCH),x86_64)
	CJ_ARCH := x86_64
else
	CJ_ARCH := unknown
endif

ifeq ($(OS),Darwin)
	export DYLD_LIBRARY_PATH := $(CANGJIE_STDX_PATH):$(CANGJIE_HOME)/runtime/lib/darwin_$(CJ_ARCH)_cjnative:$(DYLD_LIBRARY_PATH)
else ifeq ($(OS),Linux)
	export LD_LIBRARY_PATH := $(CANGJIE_STDX_PATH):$(CANGJIE_HOME)/runtime/lib/linux_$(ARCH)_cjnative:$(LD_LIBRARY_PATH)
endif

example:
	rm -rf $(EXAMPLE_TARGET_DIR)
	mkdir $(EXAMPLE_TARGET_DIR)
	$(CJC) $(BASIC_EXAMPLE_DIR)/ping-pong.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/ping-pong
	$(CJC) $(BASIC_EXAMPLE_DIR)/actor-interface.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/actor-interface
	$(CJC) $(BASIC_EXAMPLE_DIR)/actor-interface-priority.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/actor-interface-priority
	$(CJC) $(BASIC_EXAMPLE_DIR)/gc.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/gc
	$(CJC) $(BASIC_EXAMPLE_DIR)/fjcreate.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/fjcreate
	$(CJC) $(BASIC_EXAMPLE_DIR)/counter.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/counter
	$(CJC) $(BASIC_EXAMPLE_DIR)/complete-example.cj $(OPTIONS) $(IMPORT_ACTORS) -o $(EXAMPLE_TARGET_DIR)/complete-example
	pushd $(EXAMPLE_DIR)/distributed-actors-example && $(CJPM) clean && $(CJPM) build && popd && cp $(EXAMPLE_DIR)/distributed-actors-example/target/release/bin/distributed_actors_example.host $(EXAMPLE_TARGET_DIR)/distributed_actors_example.host && cp $(EXAMPLE_DIR)/distributed-actors-example/target/release/bin/distributed_actors_example.client $(EXAMPLE_TARGET_DIR)/distributed_actors_example.client
	pushd $(EXAMPLE_DIR)/serializable-proxy-example && $(CJPM) clean && $(CJPM) build && popd && cp $(EXAMPLE_DIR)/serializable-proxy-example/target/release/bin/serializable_proxy_example.host $(EXAMPLE_TARGET_DIR)/serializable_proxy_example.host && cp $(EXAMPLE_DIR)/serializable-proxy-example/target/release/bin/serializable_proxy_example.client $(EXAMPLE_TARGET_DIR)/serializable_proxy_example.client
	pushd $(EXAMPLE_DIR)/cluster-example && $(CJPM) clean && $(CJPM) build && popd && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.head_server $(EXAMPLE_TARGET_DIR)/cluster_example.head_server && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.worker $(EXAMPLE_TARGET_DIR)/cluster_example.worker && cp $(EXAMPLE_DIR)/cluster-example/target/release/bin/cluster_example.entry $(EXAMPLE_TARGET_DIR)/cluster_example.entry
	pushd $(EXAMPLE_DIR)/chat-application-example && $(CJPM) clean && $(CJPM) build && popd && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.server.head $(EXAMPLE_TARGET_DIR)/chat_app_example.server.head && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.server.worker $(EXAMPLE_TARGET_DIR)/chat_app_example.server.worker && cp $(EXAMPLE_DIR)/chat-application-example/target/release/bin/chat_app_example.client $(EXAMPLE_TARGET_DIR)/chat_app_example.client
	# pushd $(EXAMPLE_DIR)/agent-example && $(CJPM) clean && $(CJPM) build && popd && cp $(EXAMPLE_DIR)/agent-example/target/release/bin/agent_example $(EXAMPLE_TARGET_DIR)/agent_example

build:
	$(CJPM) build -i

test:
	$(CJPM) test src/tests src/tests/end2end src/macros/internal/tests src/tcp_actor_system/tests

clean:
	pushd $(EXAMPLE_DIR)/distributed-actors-example && $(CJPM) clean && popd
	pushd $(EXAMPLE_DIR)/serializable-proxy-example && $(CJPM) clean && popd
	pushd $(EXAMPLE_DIR)/cluster-example && $(CJPM) clean && popd
	pushd $(EXAMPLE_DIR)/chat-application-example && $(CJPM) clean && popd
	pushd $(EXAMPLE_DIR)/agent-example && $(CJPM) clean && popd
	$(CJPM) clean
