///|
struct NodeIndex {
  ix : Int
} derive(Eq, Compare, Show, Hash)

///|
struct EdgeIndex {
  ix : Int
  from : NodeIndex
  successor_index : Int
} derive(Show, Eq, Hash)

///|
priv struct Node[N] {
  ix : NodeIndex
  weight : N?
  mut next : (EdgeIndex, EdgeIndex)
} derive(Show, Eq, Hash)

///|
priv struct Edge[E] {
  ix : EdgeIndex
  weight : E?
  mut next : (EdgeIndex, EdgeIndex)
  node : (NodeIndex, NodeIndex)
} derive(Show, Eq, Hash)

///|
struct Graph[N, E] {
  nodes : Array[Node[N]]
  edges : Array[Edge[E]]
  directed : Bool
} derive(Show)

///|
fn NodeIndex::end() -> NodeIndex {
  NodeIndex::{ ix: @int.max_value }
}

///|
fn NodeIndex::new(ix : Int) -> NodeIndex {
  NodeIndex::{ ix, }
}

///|
fn EdgeIndex::end() -> EdgeIndex {
  EdgeIndex::{
    ix: @int.max_value,
    from: NodeIndex::end(),
    successor_index: @int.max_value,
  }
}

///|
fn EdgeIndex::new(
  ix : Int,
  from : NodeIndex,
  successor_index : Int
) -> EdgeIndex {
  EdgeIndex::{ ix, from, successor_index }
}

///| Create a new Graph with directed edges.
pub fn Graph::new[N, E](directed~ : Bool = true) -> Graph[N, E] {
  Graph::{ nodes: [], edges: [], directed }
}

///| Add a node (also called vertex) with associated data weight to the graph
pub fn Graph::add_node[N, E](self : Graph[N, E], weight? : N) -> NodeIndex {
  match weight {
    Some(w) => self.try_add_node?(weight=w).unwrap()
    None => self.try_add_node?().unwrap()
  }
}

///| Add a node (also called vertex) with associated data weight to the graph
pub fn Graph::try_add_node[N, E](self : Graph[N, E], weight? : N) -> NodeIndex! {
  let node_idx = NodeIndex::new(self.nodes.length())
  let node = Node::{
    ix: node_idx,
    weight,
    next: (EdgeIndex::end(), EdgeIndex::end()),
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

///|
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

///| Add an edge from node `a` to node `b` in the graph, with an optional weight.
///
/// Parameters
///
/// - `a` : The starting node of the edge, represented as a `NodeIndex`.
/// - `b` : The ending node of the edge, represented as a `NodeIndex`.
/// - `weight` : (Optional) The weight of the edge, represented as type `E`.
///
/// Returns
///
/// - `EdgeIndex` : The index of the newly added edge in the graph.
///
/// Example
/// ```
/// let edge_idx = graph.add_edge(node_a, node_b, weight=10)
/// ```
pub fn Graph::add_edge[N, E](
  self : Graph[N, E],
  a : NodeIndex,
  b : NodeIndex,
  weight? : E
) -> EdgeIndex {
  match weight {
    Some(w) => self.try_add_edge?(a, b, weight=w).unwrap()
    None => self.try_add_edge?(a, b).unwrap()
  }
}

///| Add an edge from a to b to the graph, with its associated data weight
pub fn Graph::try_add_edge[N, E](
  self : Graph[N, E],
  a : NodeIndex,
  b : NodeIndex,
  weight? : E
) -> EdgeIndex! {
  let edge_idx = EdgeIndex::new(self.edges.length(), NodeIndex::end(), -1)
  let edge = Edge::{
    ix: edge_idx,
    weight,
    next: (EdgeIndex::end(), EdgeIndex::end()),
    node: (a, b),
  }
  match self.index_twice(a.ix, b.ix) {
    None => raise NodeOutBounds("Node index out of bounds")
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

///|
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

///|
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
  inspect!(graph.edges[edge_ac.ix].next.0.ix, content=node_a.ix.to_string())
  inspect!(graph.edges[edge_ac.ix].next.1.ix, content="2147483647")
  inspect!(graph.nodes[node_a.ix].next.0.ix, content=edge_ac.ix.to_string())
}

///|
pub fn node_count[N, E](self : Graph[N, E]) -> Int {
  self.nodes.length()
}

///|
pub fn edge_count[N, E](self : Graph[N, E]) -> Int {
  self.edges.length()
}

///|
pub fn Graph::is_directed[N, E](self : Graph[N, E]) -> Bool {
  self.directed
}

///|
pub fn index(self : NodeIndex) -> Int {
  self.ix
}

///| Find an edge between two nodes in the graph.
///
/// Parameters
///
/// - `a` : The starting node of the edge, represented as a `NodeIndex`.
/// - `b` : The ending node of the edge, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Option[EdgeIndex]` : The index of the edge if it exists, or `None` if no such edge is found.
///
/// Example
/// ```
/// let edge_idx = graph.find_edge(node_a, node_b)
/// ```
pub fn find_edge[N, E](
  self : Graph[N, E],
  a : NodeIndex,
  b : NodeIndex
) -> EdgeIndex? {
  if not(self.directed) {
    self.find_edge_undirected(a, b)
  } else {
    match self.nodes.get(a.index()) {
      None => None
      Some(node) => self.find_edge_directed_from_node(node, b)
    }
  }
}

///|
fn find_edge_directed_from_node[N, E](
  self : Graph[N, E],
  node : Node[N],
  b : NodeIndex
) -> EdgeIndex? {
  let mut edix = node.next.0
  while self.edges.get(edix.ix) is Some(edge) {
    if edge.node.1 == b {
      return Some(edix)
    }
    edix = edge.next.0
  }
  None
}

///|
fn Node::next[N](self : Node[N], index : Int) -> EdgeIndex {
  match index {
    0 => self.next.0
    1 => self.next.1
    _ => abort("Node next get error")
  }
}

///|
fn Edge::node[E](self : Edge[E], index : Int) -> NodeIndex {
  match index {
    0 => self.node.0
    1 => self.node.1
    _ => abort("Edge node get error")
  }
}

///| Find an edge between two nodes in an undirected graph.
///
/// Parameters
///
/// - `a` : The first node of the edge, represented as a `NodeIndex`.
/// - `b` : The second node of the edge, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Option[EdgeIndex]` : The index of the edge if it exists, or `None` if no such edge is found.
///
/// Example
/// ```
/// let edge_idx = graph.find_edge_undirected(node_a, node_b)
/// ```
pub fn find_edge_undirected[N, E](
  self : Graph[N, E],
  a : NodeIndex,
  b : NodeIndex
) -> EdgeIndex? {
  match self.nodes.get(a.index()) {
    None => None
    Some(node) => self.find_edge_undirected_from_node(node, b)
  }
}

///|
fn find_edge_undirected_from_node[N, E](
  self : Graph[N, E],
  node : Node[N],
  b : NodeIndex
) -> EdgeIndex? {
  for i in 0..<2 {
    let mut edix = node.next(i)
    while self.edges.get(edix.ix) is Some(edge) {
      if edge.node(1 - i) == b {
        return Some(edix)
      }
      edix = edge.next.0
    }
  }
  None
}

///|
test "find_edge/directed" {
  let graph = Graph::new()
  let node_a = graph.add_node(weight=0)
  let node_b = graph.add_node(weight=1)
  let _ = graph.add_edge(node_a, node_b, weight=1)
  inspect!(graph.find_edge(node_a, node_b).unwrap().ix, content="0")
}

///|
test "find_edge/undirected" {
  let graph = Graph::new(directed=false)
  let node_a = graph.add_node(weight=0)
  let node_b = graph.add_node(weight=1)
  let _ = graph.add_edge(node_a, node_b, weight=1)
  inspect!(
    graph.find_edge_undirected(node_a, node_b),
    content="Some({ix: 0, from: {ix: 2147483647}, successor_index: -1})",
  )
}

///| Get all neighbors of a given node in the graph.
///
/// Parameters
///
/// - `node` : The node for which neighbors are to be retrieved, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Iter[NodeIndex]` : An iterator over the indices of the neighboring nodes.
///
/// Example
/// ```
/// let neighbors = graph.neighbors(node_a)
/// ```
pub fn Graph::neighbors[N, E](
  self : Graph[N, E],
  node : NodeIndex
) -> Iter[NodeIndex] {
  let mut res : Iter[NodeIndex] = Iter::empty()
  let mut edix = self.nodes[node.index()].next.0
  while self.edges.get(edix.ix) is Some(edge) {
    res = res.append(edge.node.1)
    edix = edge.next.0
  }
  res
}

///|
test "neighbors" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_a, node_c) |> ignore
  let nb = graph.neighbors(node_a)
  inspect!(nb.count(), content="2")
  inspect!(nb.contains(node_b), content="true")
  inspect!(nb.contains(node_c), content="true")
}
