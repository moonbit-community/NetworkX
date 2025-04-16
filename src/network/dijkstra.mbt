///| Compute the shortest paths from a starting node to all other nodes using Dijkstra's algorithm.
///
/// Parameters
///
/// - `a` : The starting node, represented as a `NodeIndex`.
///
/// Returns
///
/// - `@hashmap.T[NodeIndex, E]!` : A hashmap containing the shortest distances from the starting node to all reachable nodes.
///
/// Example
/// ```
/// let dist = graph.dijkstra!(node_start)
/// ```
pub fn Graph::dijkstra[N, E : Compare + Add + Default](
  self : Graph[N, E],
  a : NodeIndex
) -> @hashmap.T[NodeIndex, E]! {
  guard self.nodes.get(a.index()) is Some(_) else {
    raise NodeNotFound("Node not found")
  }
  let nodes_count = self.node_count()
  let vis = Array::make(nodes_count, false)
  let dist = @hashmap.new()
  let q : @priority_queue.T[(E, NodeIndex)] = @priority_queue.new()
  q.push((E::default(), a))
  while not(q.is_empty()) {
    let (d, u) = q.pop().unwrap()
    if vis[u.index()] {
      continue
    }
    vis[u.index()] = true
    let mut edix = self.nodes[u.index()].next.0
    while self.edges.get(edix.ix) is Some(edge) {
      let v = edge.node(1)
      if vis[v.index()] {
        edix = edge.next.0
        continue
      }
      let new_dist = d + edge.weight
      if dist.get(v) == None || new_dist <= dist[v].unwrap() {
        dist[v] = new_dist
        q.push((new_dist, v))
      }
      edix = edge.next.0
    }
  }
  dist
}

///|
test "dijkstra/Int" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_a, node_b, weight=1) |> ignore
  graph.add_edge(node_b, node_c, weight=2) |> ignore
  let dist = graph.dijkstra!(node_a)
  inspect!(dist[node_b].unwrap(), content="1")
  inspect!(dist[node_c].unwrap(), content="3")
}

///|
test "dijkstra/Float" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_a, node_b, weight=1.0) |> ignore
  graph.add_edge(node_b, node_c, weight=2.0) |> ignore
  graph.add_edge(node_a, node_c, weight=2.5) |> ignore
  let dist = graph.dijkstra!(node_a)
  inspect!(dist[node_b].unwrap(), content="1")
  inspect!(dist[node_c].unwrap(), content="2.5")
}
