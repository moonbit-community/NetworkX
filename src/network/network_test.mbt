///|
test "Graph::new" {
  struct weight {
    value : Int
    unit : String
  } derive(Default)
  let graph : @network.Graph[weight, Unit] = Graph::new()
  graph.add_node(weight=weight::{ value: 1, unit: "kg" }) |> ignore
}

///|
test "Graph::add_node" {
  let graph : @network.Graph[Int, Unit] = Graph::new()
  let node = graph.add_node(weight=1)
  inspect!(node.index(), content="0")
  inspect!(graph.node_count(), content="1")
}
