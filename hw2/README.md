# Project 1. Garbage collection

Copying Incremental GC

## Dependencies

- docker
- gcc
- cargo ([optional](#run-without-cargo))

## Run

```shell
bash run.sh -m <MAX_ALLOC_SIZE> -t <TEST_NAME> -i <PROGRAM_INPUT> 
```

- `<TEST_NAME>` - filename `*.st` from [tests](tests/)
- default build is **debug**, use `-b release` for **release** build

## Tests
### Unit

```shell
cargo test
```

### Integration
```shell
bash integration_tests.sh
```

## Run without `cargo`

Replace `cargo build ...` commands with:
```
docker run --rm -v "$PWD":/volume -w /volume rust cargo build ...
```
