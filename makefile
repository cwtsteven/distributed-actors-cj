all: build example

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

example:
	rm -rf ./target/examples/
	mkdir ./target/examples
	cjc ./examples/ping-pong.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/ping-pong.o
	cjc ./examples/dist-actors.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor.o
	cjc ./examples/actor-interface.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/actor-interface.o
	cjc ./examples/dist-actor-interface.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -L./lib/${OS_NAME}_${ARCH}_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor-interface.o

build:
	cjpm build

clean:
	cjpm clean