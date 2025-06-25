///|
test "dijkstra/Float" {
  let graph: @network.Graph[Unit, Float] = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_a, node_b, weight=1.0) |> ignore
  graph.add_edge(node_b, node_c, weight=2.0) |> ignore
  graph.add_edge(node_a, node_c, weight=2.5) |> ignore
  let dist = graph.dijkstra(node_a)
  inspect(dist.get(node_b).unwrap(), content="1")
  inspect(dist.get(node_c).unwrap(), content="2.5")
}

///|
test "dijkstra/Int" {
  let graph: @network.Graph[Unit, Int] = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_a, node_b, weight=1) |> ignore
  graph.add_edge(node_b, node_c, weight=2) |> ignore
  let dist = graph.dijkstra(node_a)
  inspect(dist.get(node_b).unwrap(), content="1")
  inspect(dist.get(node_c).unwrap(), content="3")
}