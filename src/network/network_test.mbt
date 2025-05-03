///|
test "Graph::new" {
  struct weight {
    // value : Int
    // unit : String
  } derive(Default)
  let graph : @network.Graph[weight, Unit] = Graph::new()
  // graph.add_node(weight=weight::{ value: 1, unit: "kg" }) |> ignore
  graph.add_node(weight=weight::{  }) |> ignore
}

///|
test "Graph::add_node" {
  let graph : @network.Graph[Int, Unit] = Graph::new()
  let node = graph.add_node(weight=1)
  inspect!(node.index(), content="0")
  inspect!(graph.node_count(), content="1")
}

///|
test "remove_node" {
  let g = Graph::new()
  let node_a = g.add_node()
  let node_b = g.add_node(weight=1)
  let node_c = g.add_node(weight=2)
  g.add_edge(node_a, node_b, weight=1) |> ignore
  g.add_edge(node_a, node_c, weight=2) |> ignore
  inspect!(g.node_count(), content="3")
  inspect!(g.edge_count(), content="2")
  inspect!(g.remove_node(node_a), content="Some(0)")
  inspect!(g.node_count(), content="2")
  inspect!(g.edge_count(), content="0")
}

///|
test "remove_node/empty" {
  let g = Graph::new()
  let node_a = g.add_node(weight=0)
  inspect!(g.node_count(), content="1")
  inspect!(g.remove_node(node_a), content="Some(0)")
  inspect!(g.node_count(), content="0")
}
