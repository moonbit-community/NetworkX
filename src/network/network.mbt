struct NodeIndex {
  ix : Int
} derive(Eq, Compare, Show)
struct EdgeIndex {
  ix : Int
  from : NodeIndex
  successor_index : Int
} derive(Show)
priv struct Node[N] {
  ix : NodeIndex
  weight : Option[N]
  mut next : (EdgeIndex, EdgeIndex)
} derive(Show)

priv struct Edge[E] {
  ix : EdgeIndex
  weight : Option[E]
  mut next : (EdgeIndex, EdgeIndex)
  node : (NodeIndex, NodeIndex)
} derive(Show)

struct Graph[N, E] {
  nodes : Array[Node[N]]
  edges : Array[Edge[E]]
  directed : Bool
} derive(Show)

///|
fn NodeIndex::end() -> NodeIndex {
  NodeIndex::{ix : @int.max_value}
}

///|
fn NodeIndex::new(ix : Int) -> NodeIndex {
  NodeIndex::{ix : ix}
}

///|
fn EdgeIndex::end() -> EdgeIndex {
  EdgeIndex::{ix : @int.max_value, from : NodeIndex::end(), successor_index : @int.max_value}
}

///|
fn EdgeIndex::new(ix : Int, from : NodeIndex, successor_index : Int) -> EdgeIndex {
  EdgeIndex::{ix : ix, from : from, successor_index : successor_index}
}

///| Create a new Graph with directed edges.
pub fn Graph::new[N, E]() -> Graph[N, E] {
  Graph::{
    nodes : [],
    edges : [],
    directed : true
  }
}

///|
pub fn Graph::add_node[N, E](self : Graph[N, E], weight? : N) -> NodeIndex {
  match weight {
    Some(w) => self.try_add_node?(weight=w).unwrap()
    None => self.try_add_node?().unwrap()
  }
}

///| Add a node (also called vertex) with associated data weight to the graph
pub fn Graph::try_add_node[N, E](self : Graph[N, E], weight? : N) -> NodeIndex! {
  let node_idx = NodeIndex::new(self.nodes.length())
  let node= Node::{
    ix : node_idx,
    weight,
    next : (EdgeIndex::end(), EdgeIndex::end())
  }
  guard node_idx < NodeIndex::end() else {
    raise NodeIxLimit("Node index limit reached")
  }
  self.nodes.push(node)
  node_idx
}

///|
test "add_node" {
  let graph = Graph::new()
  let node_idx = graph.add_node(weight=0)
  inspect!(node_idx.ix, content="0")
  let node_idx = graph.add_node()
  inspect!(node_idx.ix, content="1")
}

priv enum Pair[T] {
  Both(T, T)
  One(T)
  None
}

///|
fn index_twice[N, E](self : Graph[N, E], a : Int, b : Int) -> Pair[Node[N]] {
  let nodes = self.nodes
  if @math.maximum(a, b) >= nodes.length() {
    return None
  } else if a == b {
    return One(nodes[a])
  } else {
    return Both(nodes[a], nodes[b])
  }
}

///|
pub fn Graph::add_edge[N, E](self : Graph[N, E], a : NodeIndex, b : NodeIndex, weight? : E) -> EdgeIndex {
  match weight {
    Some(w) => self.try_add_edge?(a, b, weight=w).unwrap()
    None => self.try_add_edge?(a, b).unwrap()
  }
}

///| Add an edge from a to b to the graph, with its associated data weight
pub fn Graph::try_add_edge[N, E](self : Graph[N, E], a : NodeIndex, b : NodeIndex, weight? : E) -> EdgeIndex! {
  let edge_idx = EdgeIndex::new(self.edges.length(), NodeIndex::end(), -1)
  let edge = Edge::{
    ix : edge_idx,
    weight: weight,
    next : (EdgeIndex::end(), EdgeIndex::end()),
    node : (a, b)
  }
  match self.index_twice(a.ix, b.ix) {
    None => {
      raise NodeOutBounds("Node index out of bounds")
    }
    One(an) => {
      edge.next = an.next
      // an.next = (edge_idx, edge_idx)
      self.nodes[a.ix].next = (edge_idx, edge_idx)
    }
    Both(an, bn) => {
      edge.next = (an.next.0, bn.next.1)
      // an.next = (edge_idx, an.next.1)
      // bn.next = (bn.next.0, edge_idx)
      self.nodes[a.ix].next = (edge_idx, an.next.1)
      self.nodes[b.ix].next = (bn.next.0, edge_idx)
    }
  }
  self.edges.push(edge)
  edge_idx
}

test "add_edge" {
  let graph = Graph::new()
  let node_a = graph.add_node(weight=0)
  let node_b = graph.add_node(weight=1)
  let edge_idx = graph.add_edge(node_a, node_b, weight=1)
  inspect!(edge_idx.ix, content="0")
  inspect!(graph.edges[edge_idx.ix].weight, content="Some(1)")
  inspect!(graph.nodes[node_a.ix].next.0.ix, content="0")
  inspect!(graph.nodes[node_b.ix].next.1.ix, content="0")
}

test "add_edge/multi" {
  let graph = Graph::new()
  let node_a = graph.add_node(weight=0)
  let node_b = graph.add_node(weight=1)
  let node_c = graph.add_node(weight=2)
  inspect!(graph.nodes[node_a.ix].next.0.ix, content="2147483647")
  let edge_ab = graph.add_edge(node_a, node_b, weight=1)
  inspect!(graph.nodes[node_a.ix].next.0.ix, content="0")
  inspect!(graph.nodes[node_b.ix].next.1.ix, content="0")

  inspect!(graph.edges[edge_ab.ix].node.0.ix, content="0")
  inspect!(graph.edges[edge_ab.ix].node.1.ix, content="1")

  inspect!(graph.edges[edge_ab.ix].next.0.ix, content="2147483647")
  inspect!(graph.edges[edge_ab.ix].next.0.ix, content="2147483647")

  let edge_ac = graph.add_edge(node_a, node_c, weight=2)
  inspect!(graph.nodes[node_a.ix].next.0.ix, content="1")
  inspect!(graph.nodes[node_c.ix].next.1.ix, content="1")

  inspect!(graph.edges[edge_ac.ix].node.0.ix, content="0")
  inspect!(graph.edges[edge_ac.ix].node.1.ix, content="2")

  inspect!(graph.edges[edge_ac.ix].next.0.ix, content = node_a.ix.to_string())
  inspect!(graph.edges[edge_ac.ix].next.1.ix, content="2147483647")

  inspect!(graph.nodes[node_a.ix].next.0.ix, content=edge_ac.ix.to_string())
}