///|
struct Dfs {
  stack : Array[NodeIndex]
  discovered : VisitMap
}

///| Create a new Depth-First Search (DFS) instance starting from a given node.
///
/// Parameters
///
/// - `g` : The graph on which the DFS will be performed, represented as a `Graph[N, E]`.
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
pub fn Dfs::new[N, E](g : Graph[N, E], start : NodeIndex) -> Dfs {
  Dfs::{ stack: [start], discovered: VisitMap::new() }
}

///|
struct VisitMap {
  visit : @hashmap.T[NodeIndex, Bool]
}

///| create a new VisitMap
pub fn VisitMap::new() -> VisitMap {
  VisitMap::{ visit: @hashmap.new() }
}

///|
fn VisitMap::op_set(self : VisitMap, node : NodeIndex, count : Bool) -> Unit {
  self.visit[node] = count
}

///|
fn VisitMap::op_get(self : VisitMap, node : NodeIndex) -> Bool {
  match self.visit.get(node) {
    Some(t) => t
    None => false
  }
}

///|
impl VM for VisitMap with visit(self, node : NodeIndex) -> Bool {
  let res = self.visit.contains(node) && self.visit[node].unwrap()
  self.visit[node] = true
  not(res)
}

///|
impl VM for VisitMap with is_visited(self, node : NodeIndex) -> Bool {
  self.visit.contains(node)
}

///|
impl VM for VisitMap with unvisit(self, node : NodeIndex) -> Bool {
  if self.is_visited(node) {
    self.visit[node] = not(self.visit[node].unwrap())
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

///| create an empty Dfs
pub fn Dfs::empty() -> Dfs {
  Dfs::{ stack: [], discovered: VisitMap::new() }
}

///|
impl Default for Dfs with default() -> Dfs {
  Dfs::{
    stack: [],
    discovered: VisitMap::new()
  }
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
/// - `g` : The graph on which the DFS is being performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `NodeIndex?` : The next node in the DFS traversal if available, or `None` if the traversal is complete.
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
pub fn Dfs::next[N, E](self : Dfs, g : Graph[N, E]) -> NodeIndex? {
  while self.stack.pop() is Some(node) {
    if self.discovered.visit(node) {
      for succ in g.neighbors(node) {
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
  graph.add_edge(node_a, node_b, weight=1) |> ignore
  graph.add_edge(node_b, node_c, weight=2) |> ignore
  graph.add_edge(node_c, node_d, weight=3) |> ignore
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

impl Default for DfsPostOrder with default() -> DfsPostOrder {
  DfsPostOrder::{
    stack: [],
    discovered: VisitMap::new(),
    finished: VisitMap::new()
  }
}
///| Create a new Depth-First Search (DFS) Post-Order instance starting from a given node.
///
/// Parameters
///
/// - `g` : The graph on which the DFS Post-Order will be performed, represented as a `Graph[N, E]`.
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
pub fn DfsPostOrder::new[N, E](g : Graph[N, E], start : NodeIndex) -> DfsPostOrder {
  DfsPostOrder::{
    stack: [start],
    discovered: VisitMap::new(),
    finished: VisitMap::new()
  }
}

pub fn DfsPostOrder::reset(self : DfsPostOrder) -> Unit {
  self.stack.clear()
  self.discovered.visit.clear()
  self.finished.visit.clear()
}

pub fn DfsPostOrder::move_to(self : DfsPostOrder, node : NodeIndex) -> Unit {
  self.stack.clear()
  self.stack.push(node)
}

pub fn DfsPostOrder::next[N, E](self : DfsPostOrder, g : Graph[N, E]) -> NodeIndex? {
  while self.stack.last() is Some(node) {
    if self.discovered.visit(node) {
      for succ in g.neighbors(node) {
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

test "DfsPostOrder::next" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
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