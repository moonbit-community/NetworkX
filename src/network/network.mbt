struct NodeIndex {
  ix : Int
} derive(Eq, Compare, Show)
struct EdgeIndex {
  ix : Int
  from : NodeIndex
  successor_index : Int
} derive(Show)
struct Node[N] {
  ix : NodeIndex
  weight : Option[N]
  mut next : (EdgeIndex, EdgeIndex)
} derive(Show)

struct Edge[E] {
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
    weight: weight,
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

enum Pair[T] {
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
  guard a.ix < self.nodes.length() && b.ix < self.nodes.length() else {
    return panic()
  }
  let edge_idx = EdgeIndex::new(self.edges.length(), a, b.ix)
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
    One(ix) => {
      edge.next = ix.next
      ix.next = (edge_idx, edge_idx)
    }
    Both(ix_a, ix_b) => {
      edge.next = (ix_a.next.0, ix_b.next.1)
      ix_a.next = (edge_idx, ix_a.next.1)
      ix_b.next = (ix_b.next.0, edge_idx)
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