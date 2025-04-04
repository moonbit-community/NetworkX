///|
struct Dfs {
  stack : Array[NodeIndex]
  discovered : VisitMap
}

///| Create a new Depth-First Search (DFS) instance starting from a given node.
///
/// Parameters
///
/// - `graph` : The graph on which the DFS will be performed, represented as a `Graph[N, E]`.
/// - `start` : The starting node for the DFS, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Dfs` : A new DFS instance initialized with the starting node.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let dfs = Dfs::new(graph, node_a)
/// ```
pub fn Dfs::new[N, E](graph : Graph[N, E], start : NodeIndex) -> Dfs {
  Dfs::{ stack: [start], discovered: graph.visit_map() }
}

///|
struct VisitMap {
  // visit : @hashmap.T[NodeIndex, Bool]
  visit : Array[Bool]
}

///| create a new VisitMap
pub fn VisitMap::new() -> VisitMap {
  // VisitMap::{ visit: @hashmap.new() }
  VisitMap::{ visit: Array::new() }
}

///|
fn VisitMap::op_set(self : VisitMap, node : NodeIndex, count : Bool) -> Unit {
  self.visit[node.ix] = count
}

///|
fn VisitMap::op_get(self : VisitMap, node : NodeIndex) -> Bool {
  // match self.visit.get(node) {
  //   Some(t) => t
  //   None => false
  // }
  self.visit[node.ix]
}

///|
fn VisitMap::contain(self : VisitMap, nx : Int) -> Bool {
  self.visit[nx]
}

///|
impl VM for VisitMap with visit(self, node : NodeIndex) -> Bool {
  let nx = node.ix
  let res = self.contain(nx)
  self.visit[nx] = true
  not(res)
}

///|
impl VM for VisitMap with is_visited(self, node : NodeIndex) -> Bool {
  // self.visit.contains(node)
  self.contain(node.ix)
}

///|
impl VM for VisitMap with unvisit(self, node : NodeIndex) -> Bool {
  if self.is_visited(node) {
    // self.visit[node] = not(self.visit[node].unwrap())
    self.visit[node.ix] = not(self.visit[node.ix])
    return true
  }
  false
}

///|
priv trait VM {
  visit(Self, NodeIndex) -> Bool
  is_visited(Self, NodeIndex) -> Bool
  unvisit(Self, NodeIndex) -> Bool
}

///|
priv trait Visitable {
  visit_map(Self) -> VisitMap
  reset_map(Self, VisitMap) -> Unit
}

///|
impl[N, E] Visitable for Graph[N, E] with visit_map(self) -> VisitMap {
  VisitMap::{ visit: Array::make(self.node_count(), false) }
}

///|
impl[N, E] Visitable for Graph[N, E] with reset_map(self, map) -> Unit {
  map.clear()
  map.grow(self.node_count())
}

///|
fn VisitMap::clear(self : VisitMap) -> Unit {
  self.clear()
}

///|
fn VisitMap::grow(self : VisitMap, n : Int) -> Unit {
  self.visit.resize(n, false)
}

///| create an empty Dfs
pub fn Dfs::empty[N, E](graph : Graph[N, E]) -> Dfs {
  Dfs::{ stack: [], discovered: graph.visit_map() }
}

///|
impl Default for Dfs with default() -> Dfs {
  Dfs::{ stack: [], discovered: VisitMap::default() }
}

///| Create a new Depth-First Search (DFS) instance from given parts.
///
/// Parameters
///
/// - `stack` : An array of `NodeIndex` representing the current DFS stack.
/// - `discovered` : A `VisitMap` representing the nodes that have been discovered.
///
/// Returns
///
/// - `Dfs` : A new DFS instance initialized with the provided stack and discovered map.
///
/// Example
/// ```
/// let dfs = Dfs::from_parts(stack, discovered)
/// ```
pub fn Dfs::from_parts(stack : Array[NodeIndex], discovered : VisitMap) -> Dfs {
  Dfs::{ stack, discovered }
}

///| reset the dfs
pub fn Dfs::reset(self : Dfs) -> Unit {
  self.stack.clear()
  self.discovered.visit.clear()
}

///| Keep the discovered map, but clear the visit stack and
/// restart the dfs from a particular node.
pub fn Dfs::move_to(self : Dfs, node : NodeIndex) -> Unit {
  self.stack.clear()
  self.stack.push(node)
}

///| Perform the next step in the Depth-First Search (DFS) traversal.
///
/// Parameters
///
/// - `graph` : The graph on which the DFS is being performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Option[NodeIndex]` : The next node in the DFS traversal if available, or `None` if the traversal is complete.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let node_c = graph.add_node()
/// graph.add_edge(node_a, node_b) |> ignore
/// graph.add_edge(node_b, node_c) |> ignore
/// let mut dfs = Dfs::new(graph, node_a)
/// inspect!(dfs.next(graph), content=Some(node_a).to_string())
/// inspect!(dfs.next(graph), content=Some(node_b).to_string())
/// inspect!(dfs.next(graph), content=Some(node_c).to_string())
/// inspect!(dfs.next(graph), content=Some(node_d).to_string())
/// inspect!(dfs.next(graph), content="None")
/// ```
pub fn Dfs::next[N, E](self : Dfs, graph : Graph[N, E]) -> NodeIndex? {
  while self.stack.pop() is Some(node) {
    if self.discovered.visit(node) {
      for succ in graph.neighbors(node) {
        if not(self.discovered.is_visited(succ)) {
          self.stack.push(succ)
        }
      }
      return Some(node)
    }
  }
  None
}

///|
test "Dfs::next" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  graph.add_edge(node_c, node_d) |> ignore
  let dfs = Dfs::new(graph, node_a)
  inspect!(dfs.next(graph), content=Some(node_a).to_string())
  inspect!(dfs.next(graph), content=Some(node_b).to_string())
  inspect!(dfs.next(graph), content=Some(node_c).to_string())
  inspect!(dfs.next(graph), content=Some(node_d).to_string())
  inspect!(dfs.next(graph), content="None")
  // empty the stack
  inspect!(dfs.next(graph), content="None")
}

///|
struct DfsPostOrder {
  stack : Array[NodeIndex]
  discovered : VisitMap
  finished : VisitMap
}

///|
impl Default for VisitMap with default() -> VisitMap {
  VisitMap::{ visit: Array::new() }
}

///|
impl Default for DfsPostOrder with default() -> DfsPostOrder {
  DfsPostOrder::{
    stack: [],
    discovered: VisitMap::default(),
    finished: VisitMap::default(),
  }
}

///| Create a new Depth-First Search (DFS) Post-Order instance starting from a given node.
///
/// Parameters
///
/// - `graph` : The graph on which the DFS Post-Order will be performed, represented as a `Graph[N, E]`.
/// - `start` : The starting node for the DFS Post-Order, represented as a `NodeIndex`.
///
/// Returns
///
/// - `DfsPostOrder` : A new DFS Post-Order instance initialized with the starting node.
///
/// Example
/// ```
/// let dfs_post = DfsPostOrder::new(graph, node_a)
/// ```
pub fn DfsPostOrder::new[N, E](
  graph : Graph[N, E],
  start : NodeIndex
) -> DfsPostOrder {
  DfsPostOrder::{
    stack: [start],
    discovered: graph.visit_map(),
    finished: graph.visit_map(),
  }
}

///| reset the DfsPostOrder
pub fn DfsPostOrder::reset(self : DfsPostOrder) -> Unit {
  self.stack.clear()
  self.discovered.visit.clear()
  self.finished.visit.clear()
}

///| Keep the discovered map, but clear the visit stack and
/// restart the dfs from a particular node.
pub fn DfsPostOrder::move_to(self : DfsPostOrder, node : NodeIndex) -> Unit {
  self.stack.clear()
  self.stack.push(node)
}

///| Perform the next step in the Depth-First Search (DFS) Post-Order traversal.
///
/// Parameters
///
/// - `graph` : The graph on which the DFS Post-Order is being performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Option[NodeIndex]` : The next node in the DFS Post-Order traversal if available, or `None` if the traversal is complete.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let node_c = graph.add_node()
/// graph.add_edge(node_a, node_b) |> ignore
/// graph.add_edge(node_b, node_c) |> ignore
/// let mut dfs_post = DfsPostOrder::new(graph, node_a)
/// inspect!(dfs_post.next(graph), content=Some(node_c).to_string())
/// inspect!(dfs_post.next(graph), content=Some(node_b).to_string())
/// inspect!(dfs_post.next(graph), content=Some(node_a).to_string())
/// inspect!(dfs_post.next(graph), content="None")
/// ```
pub fn DfsPostOrder::next[N, E](
  self : DfsPostOrder,
  graph : Graph[N, E]
) -> NodeIndex? {
  while self.stack.last() is Some(node) {
    if self.discovered.visit(node) {
      for succ in graph.neighbors(node) {
        if not(self.discovered.is_visited(succ)) {
          self.stack.push(succ)
        }
      }
    } else {
      self.stack.pop() |> ignore
      if self.finished.visit(node) {
        return Some(node)
      }
    }
  }
  None
}

///|
test "DfsPostOrder::next" {
  let graph = Graph::new()
  let node_a = graph.add_node(weight=1)
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b, weight=1) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  graph.add_edge(node_c, node_d) |> ignore
  let dfs = DfsPostOrder::new(graph, node_a)
  inspect!(dfs.next(graph), content=Some(node_d).to_string())
  inspect!(dfs.next(graph), content=Some(node_c).to_string())
  inspect!(dfs.next(graph), content=Some(node_b).to_string())
  inspect!(dfs.next(graph), content=Some(node_a).to_string())
  inspect!(dfs.next(graph), content="None")
  // empty the stack
  inspect!(dfs.next(graph), content="None")
}
