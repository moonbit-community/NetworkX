///|
priv struct TestWeight {} derive(Default)

///|
test "Graph::new" {
  let graph : @network.Graph[TestWeight, Unit] = @network.Graph::new()
  graph.add_node(weight=TestWeight::{ }) |> ignore
  assert_eq(graph.node_count(), 1)
}

///|
test "Graph::add_node" {
  let graph : @network.Graph[Int32, Unit] = @network.Graph::new()
  let node = graph.add_node(weight=1)
  inspect(node.index(), content="0")
  inspect(graph.node_count(), content="1")
}

///|
test "remove_node" {
  let g = @network.Graph::new()
  let node_a = g.add_node()
  let node_b = g.add_node(weight=1)
  let node_c = g.add_node(weight=2)
  g.add_edge(node_a, node_b, weight=1) |> ignore
  g.add_edge(node_a, node_c, weight=2) |> ignore
  inspect(g.node_count(), content="3")
  inspect(g.edge_count(), content="2")
  debug_inspect(g.remove_node(node_a), content="Some(0)")
  inspect(g.node_count(), content="2")
  inspect(g.edge_count(), content="0")
}

///|
test "remove_node/empty" {
  let g : @network.Graph[Int32, Unit] = @network.Graph::new()
  let node_a = g.add_node(weight=0)
  inspect(g.node_count(), content="1")
  debug_inspect(g.remove_node(node_a), content="Some(0)")
  inspect(g.node_count(), content="0")
}
