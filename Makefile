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

example:
	rm -rf ./target/examples/
	mkdir ./target/examples
	cjc ./examples/ping-pong.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/ping-pong.o
	cjc ./examples/actor-interface.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/actor-interface.o
	cjc ./examples/dist-actor-interface.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors -lactors.dummy_actor_system --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor-interface.o
	cjc ./examples/gc.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/gc.o
	cjc ./examples/fjcreate.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/fjcreate.o
	cjc ./examples/counter.cj -g --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/counter.o

build:
	cjpm build

test:
	cjpm test

clean:
	cjpm clean