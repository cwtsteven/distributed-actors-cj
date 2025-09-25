# Distributed actors framework

## Dependency

cjc version: 0.53.18

## Build

**1. Follow the instruction on the Cangjie language homepage to setup correct environment**

**2. Run `make` to build the package and all the examples**

**3. Run `make test` to run all the tests**

All tests should pass except for the followings:
- [ FAILED ] CASE: testGarbageCollection
- [ FAILED ] CASE: testForkJoinGarbageCollection

## Tutorial

## APIs

## TODOs

- message delivery semantics, i.e. at-least-one or at-most-once, with or without retries
- MCP schema generation