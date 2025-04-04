# NetworkX

## Introduction
This is a Moonbit-based graph library supporting graph editing, traversal, and shortest path algorithms.

## Features
- Support for directed and undirected graphs
- Multiple graph algorithms implemented
- Support custom weights for nodes and edges

## Usage
### Graph
Create a graph:
```moonbit
// Create a directed graph
let graph = Graph::new()
// Create an undirected graph
let graph = Graph::new(directed=false)
```

Add nodes:
```moonbit
// weight is optional
let node_a = graph.add_node(weight=1)
```

Add edges:
```moonbit
// weight is optional
let edge = graph.add_edge(node_a, node_b, weight=2)
```

### DFS

Create a DFS object:
```moonbit
let dfs = DFS::new(graph)
```

Create a PostOrder DFS object:
```moonbit
let post_dfs = PostOrderDFS::new(graph)
```

Get the next node in the DFS traversal:
```moonbit
let next_node = dfs.next()
```

### Dijkstra
Find the shortest path using Dijkstra's algorithm:
```moonbit
let dijkstra = graph.dijkstra(start_node, 0)
```

## Contributing
Issues and pull requests are welcome. Please make sure to run all tests before submitting.

## Contact
If you have questions, feel free to open an issue in the repository. For other inquiries, contact me via email: [2421342308a@gmail.com].

## License
This project is licensed under the Apache-2.0 License. See the LICENSE file for details.

This project some design patterns, data structures, or algorithmic logic were inspired by the [petgraph](https://github.com/petgraph/petgraph) project, which is licensed under MIT and Apache 2.0.