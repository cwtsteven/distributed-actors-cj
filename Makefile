all: clean build example

EXAMPLE_DIR = ./examples

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

# export LD_LIBRARY_PATH=./target/release/actors:./lib/linux_aarch64_llvm/dynamic/stdx/:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=./target/release/actors:$LD_LIBRARY_PATH

example:
	rm -rf ./target/examples/
	mkdir ./target/examples
	cjc ./examples/ping-pong.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors  -o ./target/examples/ping-pong.o
	cjc ./examples/actor-interface.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors  -o ./target/examples/actor-interface.o
	cjc ./examples/gc.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors  -o ./target/examples/gc.o
	cjc ./examples/fjcreate.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors  -o ./target/examples/fjcreate.o
	cjc ./examples/counter.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors  -o ./target/examples/counter.o
	cjc ./examples/dist-actor-interface.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors -lactors.distributed -lactors.dummy_actor_system  -o ./target/examples/dist-actor-interface.o
	cjc ./examples/tcp-actor-host.cj -g --import-path ./target/release/actors --import-path ./target/release/magic -L./target/release/actors -L./target/release/magic -lmagic.core.tool -lmagic.mcp -lmagic.jsonable -lactors -lactors.distributed -lactors.tcp_actor_system  -o ./target/examples/tcp-actor-host.o
	cjc ./examples/tcp-actor-client.cj -g --import-path ./target/release/actors --import-path ./target/release/magic -L./target/release/actors -L./target/release/magic -lmagic.core.tool -lmagic.mcp -lmagic.jsonable -lactors -lactors.distributed -lactors.tcp_actor_system  -o ./target/examples/tcp-actor-client.o

build:
	cjpm build -i

test:
	cjpm test src/tests src/tests/end2end src/macros/internal/tests src/dummy_actor_system/tests src/tcp_actor_system/tests

clean:
	cjpm clean