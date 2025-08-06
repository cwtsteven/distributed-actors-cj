all: build example

EXAMPLE_DIR = ./examples

example:
	rm -rf ./target/examples/
	mkdir ./target/examples
	cjc ./examples/dist-actors.cj --import-path ./target/release/actors -L./target/release/actors -lactors --import-path ./lib/linux_x86_64_llvm/dynamic/stdx -L./lib/linux_x86_64_llvm/dynamic/stdx -lstdx.serialization.serialization -o ./target/examples/dist-actor.o

build:
	cjpm build

clean:
	cjpm clean