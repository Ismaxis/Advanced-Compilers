# Project 1. Garbage collection

Copying Incremental GC

## Run

```shell
bash run.sh -m <MAX_ALLOC_SIZE> -t <PROGRAM_NAME> -i <PROGRAM_INPUT> 
```

- default build is **debug**
- use `-b release` for **release** build

## Tests
### Unit

```shell
cargo test
```

### Integration
```shell
bash integration_tests.sh
```
