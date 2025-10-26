# Project 1. Garbage collection

Implementation of Copying Incremental GC for [Stella](https://fizruk.github.io/stella/) programming language

[Task](ККУК_2025_Проект_Этап_1_Сборка_мусора.pdf)

## Dependencies

- docker
- gcc
- cargo ([optional](#run-without-cargo))

## Run

```shell
bash run.sh -m <MAX_ALLOC_SIZE> -t <TEST_PROGRAM_NAME> -i <PROGRAM_INPUT> 
```

- `<TEST_PROGRAM_NAME>` - filename of **Stella** program to run ([tests](tests/)/`*.st`)
- `<MAX_ALLOC_SIZE>` — maximum heap size (in bytes) allocated for the garbage collector.
  **Possible values:** any positive integer divisible by 8, for example: `1024`, `4096`, `65536`.
  The actual heap will be split into two equal spaces (from-space and to-space), each of size `<MAX_ALLOC_SIZE>`.
  If the program tries to allocate more memory than this limit, an "out of memory" error will occur and `NULL`/`nullptr` returned
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

## Format

### Output format of `print_gc_alloc_stats()`


```
    [Copying Incremental GC]
    GC Cycles: full: <number> (started: <number>)
    Total memory allocation: <bytes> bytes (<objects> objects)
    Maximum residency: <bytes> bytes (<objects> objects)
    Total memory access: <number> reads and <number> writes
    Read barrier triggers: <number>
```

<details>
<summary>Example</summary>

```
    [Copying Incremental GC]
    GC Cycles: full: 2 (started: 3)
    Total memory allocation: 1024 bytes (32 objects)
    Maximum residency: 512 bytes (16 objects)
    Total memory access: 100 reads and 50 writes
    Read barrier triggers: 20
```
</details>

---

### Output format of `print_gc_state()`


```
================ GC STATE ================
Heap boundaries:
  from_space: <address> - <address>
  to_space:   <address> - <address>
Internal GC pointers:
  scan:  <address>
  next:  <address>
  limit: <address>
--- Objects in from-space ---
@ <address> header: [<{tag}>, {fields}] fields: [<address>, ...] (from-space)
...
--- Objects in to-space ---
@ <address> header: [<{tag}>, {fields}] fields: [<address>, ...] (to-space)
...
Roots [<count>]:
  [0] <address>
  [1] <address>
Allocated memory: <bytes> bytes
Free memory:      <bytes> bytes
==========================================
```

<details>
<summary>Example</summary>

```
================ GC STATE ================
Heap boundaries:
  from_space: 0x7f8c0000 - 0x7f8c0200
  to_space:   0x7f8c0200 - 0x7f8c0400
Internal GC pointers:
  scan:  0x7f8c0200
  next:  0x7f8c0240
  limit: 0x7f8c03c0
--- Objects in from-space ---
@ 0x7f8c0000 header: [<SUCC>, 3] fields: [0x7f8c0010, 0x7f8c0020, 0x7f8c0030] (from-space)
...
--- Objects in to-space ---
@ 0x7f8c0200 header: [<FN>, 3] fields: [0x7f8c0210, 0x7f8c0220, 0x7f8c0230] (to-space)
...
Roots [2]:
  [0] 0x7f8c0010
  [1] 0x7f8c0030
Allocated memory: 192 bytes
Free memory:      320 bytes
==========================================
```
</details>


## Run without `cargo`

Replace `cargo build ...` commands with:
```
docker run --rm -v "$PWD":/volume -w /volume rust cargo build ...
```
