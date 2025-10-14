#include "gc.h"
#include <stdio.h>

/** Allocate an object on the heap of AT LEAST size_in_bytes bytes.
 * If necessary, this should start/continue garbage collection.
 * Returns a pointer to the newly allocated object.
 */
void *gc_alloc(size_t size_in_bytes) {
  printf("gc_alloc: %zu\n", size_in_bytes);
  return NULL;
}

/** GC-specific code which must be executed on each READ operation.
 */
void gc_read_barrier(void *object, int field_index) {
  printf("gc_read_barrier: object=%p, field_index=%d\n", object, field_index);
}
/** GC-specific code which must be executed on each WRITE operation
 * (except object field initialization).
 */
void gc_write_barrier(void *object, int field_index, void *contents) {
  printf("gc_write_barrier: object=%p, field_index=%d, content=%p\n", object,
         field_index, contents);
}

/** Push a reference to a root (variable) on the GC's stack of roots.
 */
void gc_push_root(void **object) {
  printf("gc_push_root: object=%p\n", object);
}
/** Pop a reference to a root (variable) on the GC's stack of roots.
 * The argument must be at the top of the stack.
 */
void gc_pop_root(void **object) { printf("gc_pop_root: object=%p\n", object); }

/** Print GC statistics. Output must include at least:
 *
 * 1. Total allocated memory (bytes and objects).
 * 2. Maximum residency (bytes and object).
 * 3. Memory usage (number of reads and writes).
 * 4. Number of read/write barrier triggers.
 * 5. Total number of GC cycles (for each generation, if applicable).
 */
void print_gc_alloc_stats() { printf("print_gc_alloc_stats"); }

/** Print GC state. Output must include at least:
 *
 * 1. Heap state.
 * 2. Set of roots (or heap pointers immediately available from roots).
 * 3. Current allocated memory (bytes and objects).
 * 4. GC variable values (e.g. scan/next/limit variables in a copying
 * collector).
 */
void print_gc_state() { printf("print_gc_state"); }

/** Print current GC roots (addresses).
 * May be useful for debugging.
 */
void print_gc_roots() { printf("print_gc_roots"); }
