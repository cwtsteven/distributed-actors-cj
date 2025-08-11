all: build example

EXAMPLE_DIR = ./examples

example:
	rm -rf ./target/examples/
	mkdir ./target/examples
	cjc ./examples/ping-pong.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/linux_x86_64_llvm/dynamic/stdx -L./lib/linux_x86_64_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/ping-pong.o
	cjc ./examples/dist-actors.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/linux_x86_64_llvm/dynamic/stdx -L./lib/linux_x86_64_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor.o
	cjc ./examples/actor-interface.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/linux_x86_64_llvm/dynamic/stdx -L./lib/linux_x86_64_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/actor-interface.o
	cjc ./examples/dist-actor-interface.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/linux_x86_64_llvm/dynamic/stdx -L./lib/linux_x86_64_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor-interface.o

build:
	cjpm build

clean:
	cjpm clean