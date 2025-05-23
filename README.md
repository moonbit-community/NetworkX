# NetworkX

## Introduction
This is a Moonbit-based graph library supporting graph editing, traversal, and shortest path algorithms.

## Features
- Support for directed and undirected graphs
- Multiple graph algorithms implemented
- Support custom weights for nodes and edges
- Support for depth-first search (DFS) and breadth-first search (BFS)
- Support for Dijkstra / Topological / LCA algorithms

## Usage
### Graph
Create a graph:
```moonbit
// directed is optional, default is true
let graph = Graph::new()
```

Create graph from edges:
```moonbit
let edges = [(1, 2), (2, 3), (3, 4)]
let graph = Graph::from_edges(edges.iter())

let edges_with_weights = [(1, 2, 1.5), (2, 3, 2.5)]
let graph = Graph::from_edges_with_weights(edges_with_weights.iter())
```

Add nodes & edges:
```moonbit
// weight is optional
let node_a = graph.add_node(weight=1)

let edge = graph.add_edge(node_a, node_b, weight=2)
```

Remove nodes & edges:
```moonbit
let removed_node_weight = graph.remove_node(node_ix)

let removed_edge_weight = graph.remove_edge(edge_ix)
```

### DFS

Create a DFS object:
```moonbit
let dfs = DFS::new(graph, start_node)
```

Create a PostOrder DFS object:
```moonbit
let post_dfs = PostOrderDFS::new(graph, start_node)
```

Get the next node in the DFS traversal:
```moonbit
let next_node = dfs.next()
```

### BFS
Create a BFS object:
```moonbit
let bfs = BFS::new(graph, start_node)
```

Get the next node in the BFS traversal:
```moonbit
let next_node = bfs.next()
```

### Dijkstra
Find the shortest path using Dijkstra's algorithm:
```moonbit
let dijkstra = graph.dijkstra(start_node)
```

### Topological
Create a Topo object:
```moonbit
let topo = Topo::new(graph)
```

Get the next node in the topological order:
```moonbit
let next_node = topo.next()
```

### LCA
Create a LCA object:
```moonbit
let lca = LCA::new!(graph, root_node)
```

Find the lowest common ancestor of two nodes:
```moonbit
let ancestor = lca.lca(node_a, node_b)
```

## Contributing
Issues and pull requests are welcome. Please make sure to run all tests before submitting.

## Contact
If you have questions, feel free to open an issue in the repository. For other inquiries, contact me via email: [2421342308a@gmail.com].

## License
This project is licensed under the Apache-2.0 License. See the LICENSE file for details.
