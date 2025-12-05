from collections import defaultdict
import json


f = """с = a - b
d = a * b
e = a
h = a - b
a = d
f = b * e
g = e - b
d = a + d
a = b
u = e - a
v = c * h
c = e - a
u = c * u
h = e - a
c = g * v
v = d + f
f = h * u
a = v + c
b = a * f"""

lines = [x.strip() for x in f.split("\n")]

T = defaultdict(list)
N = 0

for i, line in enumerate(lines):
    lhs, rhs = [x.strip() for x in line.split("=")]
    if len(rhs) == 1:
        if rhs in T:
            T[lhs].append(T[rhs][-1])
            print(f"{lhs} -> {T[rhs][-1]}")
        else:
            N += 1
            T[lhs].append(N)
            print(f"{lhs} -> {N}")
        continue
    b, op, c = [x.strip() for x in rhs.split(" ")]
    if b in T:
        nb = T[b][-1]
    else:
        N += 1
        nb = N
        T[b].append(nb)
        print(f"{b} -> {nb}")
    if c in T:
        nc = T[c][-1]
    else:
        N += 1
        nc = N
        T[c].append(nc)
        print(f"{c} -> {nc}")
    if op == "*" or op == "+":
        nb, nc = min(nb, nc), max(nb, nc)
    if (nb, op, nc) in T:
        m = T[(nb, op, nc)][-1]
        T[lhs].append(m)
        print(f"{lhs} -> {m}")
    else:
        N = N + 1
        T[(nb, op, nc)].append(N)
        print(f"{(nb, op, nc)} -> {N}")
        T[lhs].append(N)
        print(f"{lhs} -> {N}")

print()
print()

for k, v in T.items():
    print(f"{k}: {v}")


T_reversed = {}

for k, vs in T.items():
    if isinstance(k, tuple):
        assert len(vs) == 1
        T_reversed[vs[0]] = k
    else:
        for i, v in enumerate(vs):
            if v not in T_reversed:
                T_reversed[v] = f"{k}_{i}"

print()
print()

for k, v in T_reversed.items():
    print(f"{k}: {v}")

vertex = {}
edges = set()


def build(k):
    global T_reversed, T, vertex, edges
    vs = T_reversed[k]
    if isinstance(vs, str):
        vertex[k] = ()
        return vs
    lhs, op, rhs = T_reversed[k]
    vertex[k] = op
    left = build(lhs)
    edges.add((k, lhs))
    if lhs == rhs:
        print("!!!", k, lhs, rhs)
        right = left
        return {"left": left, "op": op, "index": k}
    else:
        edges.add((k, rhs))
        right = build(rhs)
    
    if k == 10:
        print("!!!", k, lhs, rhs)
    return {"left": left, "right": right, "op": op, "index": k}


max_k = max(T_reversed.keys())
print(json.dumps(build(max_k), indent=2))

print(json.dumps(vertex, indent=2))
print(edges)


