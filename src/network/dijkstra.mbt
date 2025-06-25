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
pub fn[N, E : Compare + Add + Default] Graph::dijkstra(
  self : Graph[N, E],
  a : NodeIndex
) -> @hashmap.T[NodeIndex, E] raise {
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
      if dist.get(v) == None || new_dist <= dist.get(v).unwrap() {
        dist[v] = new_dist
        q.push((new_dist, v))
      }
      edix = edge.next.0
    }
  }
  dist
}




