import networkx as nx


def build_graph(edges):
    G = nx.DiGraph()
    G.add_edges_from(edges)
    return G

edges = [
    (1, 2),
    (2, 3),
    (2, 4),
    (3, 2),
    (4, 2),
    (4, 5),
    (4, 6),
    (5, 7),
    (5, 8),
    (6, 7),
    (7, 11),
    (8, 9),
    (9, 8),
    (9, 10),
    (10, 5),
    (10, 5),
]

G = build_graph()
x = sorted((u, sorted(df)) for u, df in nx.dominance_frontiers(G, 1).items())
print(*x, sep="\n")


edges = [
    (1, 2),
    (1, 13),
    (2, 3),
    (2, 12),
    (3, 4),
    (3, 8),
    (4, 5),
    (5, 6),
    (5, 7),
    (6, 5),
    (7, 2),
    (8, 7),
    (8, 11),
    (11, 8),
    (12, 13),
]
edges = [(y, x) for x, y in edges]

G = build_graph()
x = sorted((u, sorted(df)) for u, df in nx.dominance_frontiers(G, 13).items())
print(*x, sep="\n")
