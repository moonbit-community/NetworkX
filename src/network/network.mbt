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
  weight : N
  mut next : (EdgeIndex, EdgeIndex)
} derive(Show, Eq, Hash)

///|
struct Edge[E] {
  ix : EdgeIndex
  weight : E
  mut next : (EdgeIndex, EdgeIndex)
  mut node : (NodeIndex, NodeIndex)
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
pub fn Graph::add_node[N : Default, E](
  self : Graph[N, E],
  weight? : N
) -> NodeIndex {
  match weight {
    Some(w) => self.try_add_node?(weight=w).unwrap()
    None => self.try_add_node?().unwrap()
  }
}

///| Add a node (also called vertex) with associated data weight to the graph
pub fn Graph::try_add_node[N : Default, E](
  self : Graph[N, E],
  weight? : N
) -> NodeIndex! {
  let node_idx = NodeIndex::new(self.nodes.length())
  let node = Node::{
    ix: node_idx,
    weight: weight.or(N::default()),
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
pub fn Graph::add_edge[N, E : Default](
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
pub fn Graph::try_add_edge[N, E : Default](
  self : Graph[N, E],
  a : NodeIndex,
  b : NodeIndex,
  weight? : E
) -> EdgeIndex! {
  let edge_idx = EdgeIndex::new(self.edges.length(), NodeIndex::end(), -1)
  let edge = Edge::{
    ix: edge_idx,
    weight: weight.or(E::default()),
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
  inspect!(graph.edges[edge_idx.ix].weight, content="1")
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
  inspect!(graph.edges[edge_ab.ix].next.1.ix, content="2147483647")
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

///| return the capacity of the graph (nodes and edges)
pub fn Graph::capacity[N, E](self : Graph[N, E]) -> (Int, Int) {
  (self.nodes.capacity(), self.edges.capacity())
}

///| Retrieve all edges connected to a given node in the graph.
///
/// Parameters
///
/// - `node` : The node for which edges are to be retrieved, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Iter[Edge[E]]` : An iterator over the edges connected to the given node.
///
/// Example
/// ```
/// let edges = graph.edges(node_a)
/// ```
pub fn Graph::edges[N, E : Eq + Hash](
  self : Graph[N, E],
  node : NodeIndex
) -> Iter[Edge[E]] {
  let edges = @hashset.new()
  for i in 0..<(2 - self.directed.to_int()) {
    let mut edix = self.nodes[node.index()].next(i)
    while self.edges.get(edix.ix) is Some(edge) {
      edges.add(edge)
      edix = edge.next(i)
    }
  }
  edges.iter()
}

///|
test "edges" {
  let graph = Graph::new(directed=false)
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  graph.add_edge(node_b, node_a) |> ignore
  graph.add_edge(node_c, node_a) |> ignore
  let edges = graph.edges(node_a)
  inspect!(edges.count(), content="2")
  inspect!(edges.contains(graph.edges[0]), content="true")
  inspect!(edges.contains(graph.edges[1]), content="true")
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
fn Edge::next[E](self : Edge[E], index : Int) -> EdgeIndex {
  match index {
    0 => self.next.0
    1 => self.next.1
    _ => abort("Edge next get error")
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
      edix = edge.next(i)
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

///| Create a new graph with specified capacities for nodes and edges.
///
/// Parameters
///
/// - `nodes_capacity` : The initial capacity for the nodes array.
/// - `edges_capacity` : The initial capacity for the edges array.
/// - `directed~` : WWhether the graph is directed. Defaults to `true`.
///
/// Returns
///
/// - `Graph[N, E]` : A new graph instance with the specified capacities.
///
/// Example
/// ```
/// let graph = Graph::with_capacity(10, 10, directed=false)
/// ```
pub fn Graph::with_capacity[N, E](
  nodes_capacity : Int,
  edges_capacity : Int,
  directed~ : Bool = true
) -> Graph[N, E] {
  Graph::{
    nodes: Array::new(capacity=nodes_capacity),
    edges: Array::new(capacity=edges_capacity),
    directed,
  }
}

///| Extend the graph by adding edges from an iterable of node pairs.
///  (N, N) is weighted of node pairs, the same weight are considered the same point!
///
/// Parameters
///
/// - `iterable` : An iterator over pairs of nodes `(N, N)` to be added as edges.
///
/// Returns
///
/// - `Unit` : This function modifies the graph in place.
///
/// Example
/// ```
/// let edges = [(1, 2), (2, 3)]
/// graph.extend_with_edges(edges.iter())
/// ```
pub fn Graph::extend_with_edges[N : Default + Eq + Hash, E : Default](
  self : Graph[N, E],
  iterable : Iter[(N, N)]
) -> Unit {
  let mp : @hashmap.T[N, NodeIndex] = @hashmap.new()
  for node in self.nodes {
    mp[node.weight] = node.ix
  }
  for elt in iterable {
    let (a, b) = elt
    let a_idx = mp.get_or_init(a, fn() {
      let idx = self.add_node(weight=a)
      mp[a] = idx
      idx
    })
    let b_idx = mp.get_or_init(b, fn() {
      let idx = self.add_node(weight=b)
      mp[b] = idx
      idx
    })
    self.add_edge(a_idx, b_idx) |> ignore
  }
}

///| Create a new graph from an iterable of node pairs.
///  (N, N) is weighted of node pairs, the same weight are considered the same point!
///
/// Parameters
///
/// - `iters` : An iterator over pairs of nodes `(N, N)` to be added as edges.
/// - `directed~` : Whether the graph is directed. Defaults to `true`.
///
/// Returns
///
/// - `Graph[N, E]` : A new graph instance with the specified edges.
///
/// Example
/// ```
/// let graph = Graph::from_edges([(1, 2), (2, 3)].iter())
/// ```
pub fn Graph::from_edges[N : Default + Eq + Hash, E : Default](
  iters : Iter[(N, N)],
  directed~ : Bool = true
) -> Graph[N, E] {
  let g = Graph::with_capacity(0, 0, directed~)
  g.extend_with_edges(iters)
  g
}

///|
test "from_edges" {
  let g = Graph::from_edges([(1, 2), (2, 3)].iter())
  inspect!(g.node_count(), content="3")
  inspect!(g.edge_count(), content="2")
  inspect!(
    g.find_edge_undirected(NodeIndex::new(0), NodeIndex::new(1)),
    content="Some({ix: 0, from: {ix: 2147483647}, successor_index: -1})",
  )
}

///| Extend the graph by adding edges with weights from an iterable of node triples.
///  `N` is weighted of node pairs, the same weight are considered the same point!
///
/// Parameters
///
/// - `iterable` : An iterator over triples `(N, N, E)` where `N` represents nodes and `E` represents edge weights.
///
/// Returns
///
/// - `Unit` : This function modifies the graph in place.
///
/// Example
/// ```
/// let edges = [(1, 2, 10), (2, 3, 20)]
/// graph.extend_with_edges_with_weights(edges.iter())
/// ```
pub fn Graph::extend_with_edges_with_weights[N : Default + Eq + Hash, E : Default](
  self : Graph[N, E],
  iterable : Iter[(N, N, E)]
) -> Unit {
  let mp : @hashmap.T[N, NodeIndex] = @hashmap.new()
  for elt in iterable {
    let (a, b, w) = elt
    let a_idx = mp.get_or_init(a, fn() {
      let idx = self.add_node(weight=a)
      mp[a] = idx
      idx
    })
    let b_idx = mp.get_or_init(b, fn() {
      let idx = self.add_node(weight=b)
      mp[b] = idx
      idx
    })
    self.add_edge(a_idx, b_idx, weight=w) |> ignore
  }
}

///| Create a new graph from an iterable of node triples with weights.
///  `N` is weighted of node pairs, the same weight are considered the same point!
///
/// Parameters
///
/// - `iters` : An iterator over triples `(N, N, E)` where `N` represents nodes and `E` represents edge weights.
/// - `directed~` : Whether the graph is directed. Defaults to `true`.
///
/// Returns
///
/// - `Graph[N, E]` : A new graph instance with the specified edges and weights.
///
/// Example
/// ```
/// let graph = Graph::from_edges_with_weights([(1, 2, 10), (2, 3, 20)].iter(), directed=false)
/// ```
pub fn Graph::from_edges_with_weights[N : Default + Eq + Hash, E : Default](
  iters : Iter[(N, N, E)],
  directed~ : Bool = true
) -> Graph[N, E] {
  let g = Graph::with_capacity(0, 0, directed~)
  g.extend_with_edges_with_weights(iters)
  g
}

///|
test "from_edges_with_weights" {
  let g = Graph::from_edges_with_weights([(1, 2, 1), (2, 3, 2)].iter())
  inspect!(g.node_count(), content="3")
  inspect!(g.edge_count(), content="2")
  inspect!(
    g.find_edge_undirected(NodeIndex::new(0), NodeIndex::new(1)),
    content="Some({ix: 0, from: {ix: 2147483647}, successor_index: -1})",
  )
  inspect!(g.edges[0].weight, content="1")
  inspect!(g.edges[1].weight, content="2")
}

///| Check if the graph contains a cycle.
///
/// Parameters
///
/// - `self` : The graph to be checked, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Bool` : `true` if the graph contains a cycle, `false` otherwise.
///
/// Example
/// ```
/// let g = Graph::from_edges([(1, 2), (2, 3)].iter())
/// inspect!(g.is_cyclic(), content="false")
/// g.add_edge(NodeIndex::new(0), NodeIndex::new(2)) |> ignore
/// inspect!(g.is_cyclic(), content="false")
/// g.add_edge(NodeIndex::new(2), NodeIndex::new(0)) |> ignore
/// inspect!(g.is_cyclic(), content="true")
/// ```
pub fn Graph::is_cyclic[N, E](self : Graph[N, E]) -> Bool {
  let topo = Topo::new(self)
  while topo.next(self) is Some(_) {

  }
  topo.degrees.iter().any(fn(d) { d != 0 })
}

///|
test "Graph::is_cyclic/directed" {
  let g = Graph::from_edges([(1, 2), (2, 3)].iter())
  inspect!(g.is_cyclic(), content="false")
  g.add_edge(NodeIndex::new(0), NodeIndex::new(2)) |> ignore
  inspect!(g.is_cyclic(), content="false")
  g.add_edge(NodeIndex::new(2), NodeIndex::new(0)) |> ignore
  inspect!(g.is_cyclic(), content="true")
}

///|
test "Graph::is_cyclic/undirected" {
  let g = Graph::from_edges([(1, 2), (2, 3)].iter(), directed=false)
  inspect!(g.is_cyclic(), content="false")
  g.add_edge(NodeIndex::new(0), NodeIndex::new(2)) |> ignore
  inspect!(g.is_cyclic(), content="false")
}

///|
fn EdgeIndex::index(self : EdgeIndex) -> Int {
  self.ix
}

///| 
fn directions[N, E](self : Graph[N, E]) -> Array[Int] {
  if self.directed {
    [0]
  } else {
    [0, 1]
  }
}

///| Adjust the edge links in the graph after an edge is removed or modified.
///
/// Parameters
///
/// - `edge_node` : A tuple `(NodeIndex, NodeIndex)` representing the nodes connected by the edge.
/// - `e` : The edge to be adjusted, represented as an `EdgeIndex`.
/// - `edge_next` : A tuple `(EdgeIndex, EdgeIndex)` representing the next edges in the adjacency list.
///
/// Returns
///
/// - `Unit` : This function modifies the graph in place.
///
fn change_edge_links[N, E](
  self : Graph[N, E],
  edge_node : (NodeIndex, NodeIndex),
  e : EdgeIndex,
  edge_next : (EdgeIndex, EdgeIndex)
) -> Unit {
  for d in directions(self) {
    let k = d
    let node = match self.nodes.get(get_tuple(edge_node, k).index()) {
      Some(r) => r
      None => {
        abort("Node index out of bounds")
        return
      }
    }
    let fst = node.next(k)
    if fst == e {
      self.nodes[node.ix.ix].next = set_tuple(
        node.next,
        k,
        get_tuple(edge_next, k),
      )
    } else {
      let mut prev = fst
      while self.edges.get(prev.ix) is Some(edge) {
        if edge.next(k) == e {
          self.nodes[prev.ix].next = set_tuple(
            edge.next,
            k,
            get_tuple(edge_next, k),
          )
          break
        }
        prev = edge.next(k)
      }
    }
  }
}

///| Adjust the indices of edges in the graph after removing an edge.
///
/// Parameters
///
/// - `e` : The edge to be removed, represented as an `EdgeIndex`.
///
/// Returns
///
/// - `Option[E]` : The weight of the removed edge if it exists, or `None` if the edge does not exist.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let edge = graph.add_edge(node_a, node_b, weight=10)
/// inspect!(graph.remove_edge_adjust_indices(edge), content="Some(10)")
/// ```
fn remove_edge_adjust_indices[N, E](self : Graph[N, E], e : EdgeIndex) -> E? {
  let last_index = self.edges.length() - 1
  if e.index() != last_index {
    self.edges.swap(e.index(), last_index)
  }
  let edge = self.edges.remove(last_index)
  let swap = match self.edges.get(e.index()) {
    None => return Some(edge.weight)
    Some(ed) => ed
  }
  let swapped_e = EdgeIndex::new(self.edges.length(), edge.node.0, -1)
  self.change_edge_links(swap.node, swapped_e, (e, e))
  Some(edge.weight)
}

///| Remove an edge from the graph.
///
/// Parameters
///
/// - `e` : The edge to be removed, represented as an `EdgeIndex`.
///
/// Returns
///
/// - `Option[E]` : The weight of the removed edge if it exists, or `None` if the edge does not exist.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let edge = graph.add_edge(node_a, node_b, weight=10)
/// inspect!(graph.remove_edge(edge), content="Some(10)")
/// ```
pub fn remove_edge[N, E](self : Graph[N, E], e : EdgeIndex) -> E? {
  let (edge_node, edge_next) = match self.edges.get(e.index()) {
    None => return None
    Some(x) => (x.node, x.next)
  }
  self.change_edge_links(edge_node, e, edge_next)
  self.remove_edge_adjust_indices(e)
}

///|
test "remove_edge/single" {
  let g = Graph::new()
  let node_a = g.add_node(weight=0)
  let node_b = g.add_node(weight=1)
  let node_c = g.add_node(weight=2)
  let edge_ab = g.add_edge(node_a, node_b, weight=1)
  g.add_edge(node_a, node_c, weight=2) |> ignore
  inspect!(g.edge_count(), content="2")
  inspect!(g.remove_edge(edge_ab), content="Some(1)")
  inspect!(g.edge_count(), content="1")
  inspect!(g.find_edge(node_a, node_b), content="None")
}

///|
test "remove_edge/multi" {
  let g = Graph::new()
  let node_a = g.add_node(weight=0)
  let node_b = g.add_node(weight=1)
  let node_c = g.add_node(weight=2)
  let edge_ab = g.add_edge(node_a, node_b, weight=1)
  let edge_ac = g.add_edge(node_a, node_c, weight=2)
  inspect!(g.edge_count(), content="2")
  inspect!(g.remove_edge(edge_ab), content="Some(1)")
  inspect!(g.edge_count(), content="1")
  inspect!(g.find_edge(node_a, node_b), content="None")
  // beacause the edge_ac is removed to the start of the list
  // so ix chenge from 1 -> 0
  let edge_ac = EdgeIndex::new(0, edge_ac.from, edge_ac.successor_index)
  inspect!(g.remove_edge(edge_ac), content="Some(2)")
  inspect!(g.edge_count(), content="0")
  inspect!(g.find_edge(node_a, node_c), content="None")
}

///| Remove a node from the graph.
///
/// Parameters
///
/// - `a` : The node to be removed, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Option[N]` : The weight of the removed node if it exists, or `None` if the node does not exist.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node(weight=1)
/// inspect!(graph.remove_node(node_a), content="Some(1)")
/// ```
pub fn remove_node[N, E](self : Graph[N, E], a : NodeIndex) -> N? {
  guard self.nodes.get(a.index()) is Some(_) else { return None }
  fn remove_chain(a : NodeIndex, k : Int) -> Unit {
    let next = self.nodes[a.index()].next(k)
    if next == EdgeIndex::end() {
      return
    }
    self.remove_edge(next) |> ignore
    remove_chain(a, k)
  }

  for d in directions(self) {
    let k = d
    remove_chain(a, k)
  }
  // remove the node
  let last_index = self.nodes.length() - 1
  if a.index() != last_index {
    self.nodes.swap(a.index(), last_index)
  }
  let node = self.nodes.remove(last_index)
  let swap_edges = match self.edges.get(a.index()) {
    None => return Some(node.weight)
    Some(ed) => ed.next
  }

  // let old_index = NodeIndex::new(self.nodes.length())
  let new_index = a
  for d in directions(self) {
    let k = d
    let mut cur = get_tuple(swap_edges, k)
    while cur != EdgeIndex::end() {
      let next = get_tuple(self.edges[cur.index()].next, k)
      self.edges[cur.index()].node = set_tuple(
        self.edges[cur.index()].node,
        k,
        new_index,
      )
      cur = next
    }
  }
  Some(node.weight)
}
