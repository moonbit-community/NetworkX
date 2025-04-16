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

///|
struct Bfs {
  stack : @deque.T[NodeIndex]
  discovered : VisitMap
}

///|
impl Default for Bfs with default() -> Bfs {
  Bfs::{ stack: @deque.new(), discovered: VisitMap::default() }
}

///| Create a new Breadth-First Search (BFS) instance starting from a given node.
///
/// Parameters
///
/// - `graph` : The graph on which the BFS will be performed, represented as a `Graph[N, E]`.
/// - `start` : The starting node for the BFS, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Bfs` : A new BFS instance initialized with the starting node.
///
/// Example
/// ```
/// let bfs = Bfs::new(graph, start_node)
/// ```
pub fn Bfs::new[N, E](graph : Graph[N, E], start : NodeIndex) -> Bfs {
  let stack = @deque.new()
  stack.push_front(start)
  let discovered = graph.visit_map()
  discovered.visit(start) |> ignore
  Bfs::{ stack, discovered }
}

///| Perform the next step in the Breadth-First Search (BFS) traversal.
///
/// Parameters
///
/// - `graph` : The graph on which the BFS is being performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Option[NodeIndex]` : The next node in the BFS traversal if available, or `None` if the traversal is complete.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let node_c = graph.add_node()
/// let node_d = graph.add_node()
/// graph.add_edge(node_a, node_d) |> ignore
/// graph.add_edge(node_a, node_b) |> ignore
/// graph.add_edge(node_b, node_c) |> ignore
/// let bfs = Bfs::new(graph, node_a)
/// inspect!(bfs.next(graph), content=Some(node_a).to_string())
/// inspect!(bfs.next(graph), content=Some(node_b).to_string())
/// inspect!(bfs.next(graph), content=Some(node_d).to_string())
/// inspect!(bfs.next(graph), content=Some(node_c).to_string())
/// inspect!(bfs.next(graph), content="None")
/// ```
pub fn Bfs::next[N, E](self : Bfs, graph : Graph[N, E]) -> NodeIndex? {
  if self.stack.pop_front() is Some(node) {
    for succ in graph.neighbors(node) {
      if self.discovered.visit(succ) {
        self.stack.push_back(succ)
      }
    }
    return Some(node)
  }
  None
}

///|
test "Bfs::next" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  graph.add_edge(node_c, node_d) |> ignore
  let bfs = Bfs::new(graph, node_a)
  inspect!(bfs.next(graph), content=Some(node_a).to_string())
  inspect!(bfs.next(graph), content=Some(node_b).to_string())
  inspect!(bfs.next(graph), content=Some(node_c).to_string())
  inspect!(bfs.next(graph), content=Some(node_d).to_string())
  inspect!(bfs.next(graph), content="None")
}

///|
test "Bfs::next/multi" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_d) |> ignore
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  let bfs = Bfs::new(graph, node_a)
  inspect!(bfs.next(graph), content=Some(node_a).to_string())
  inspect!(bfs.next(graph), content=Some(node_b).to_string())
  inspect!(bfs.next(graph), content=Some(node_d).to_string())
  inspect!(bfs.next(graph), content=Some(node_c).to_string())
  inspect!(bfs.next(graph), content="None")
}

///|
struct Topo {
  tovisit : Array[NodeIndex]
  ordered : VisitMap
  degrees : Array[Int]
}

///|
impl Default for Topo with default() -> Topo {
  Topo::{
    tovisit: Array::new(),
    ordered: VisitMap::default(),
    degrees: Array::new(),
  }
}

///| Create a new Topological Sort (Topo) instance for a given graph.
///
/// Parameters
///
/// - `graph` : The graph on which the topological sort will be performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Topo` : A new Topo instance initialized with the graph's nodes and their in-degrees.
///
/// Example
/// ```
/// let topo = Topo::new(graph)
/// ```
pub fn Topo::new[N, E](graph : Graph[N, E]) -> Topo {
  let degrees = get_indegree(graph)
  let ordered = graph.visit_map()
  let tovisit = Array::new()
  for i in 0..<graph.node_count() {
    if degrees[i] == 0 {
      tovisit.push(NodeIndex::new(i))
    }
  }
  Topo::{ tovisit, ordered, degrees }
}

///| Create an empty Topo instance.
pub fn Topo::empty[N, E](graph : Graph[N, E]) -> Topo {
  Topo::{
    tovisit: Array::new(),
    ordered: graph.visit_map(),
    degrees: Array::new(),
  }
}

///| Perform the next step in the Topological Sort (Topo) traversal.
///
/// Parameters
///
/// - `graph` : The graph on which the topological sort is being performed, represented as a `Graph[N, E]`.
///
/// Returns
///
/// - `Option[NodeIndex]` : The next node in the topological order if available, or `None` if the traversal is complete.
///
/// Example
/// ```
/// let graph = Graph::new()
/// let node_a = graph.add_node()
/// let node_b = graph.add_node()
/// let node_c = graph.add_node()
/// let node_d = graph.add_node()
/// graph.add_edge(node_a, node_d) |> ignore
/// graph.add_edge(node_b, node_d) |> ignore
/// graph.add_edge(node_c, node_b) |> ignore
/// graph.add_edge(node_c, node_a) |> ignore
/// graph.add_edge(node_a, node_b) |> ignore
/// let topo = Topo::new(graph)
/// inspect!(topo.next(graph), content=Some(node_c).to_string())
/// inspect!(topo.next(graph), content=Some(node_a).to_string())
/// inspect!(topo.next(graph), content=Some(node_b).to_string())
/// inspect!(topo.next(graph), content=Some(node_d).to_string())
/// inspect!(topo.next(graph), content="None")
/// ```
pub fn Topo::next[N, E](self : Topo, graph : Graph[N, E]) -> NodeIndex? {
  while self.tovisit.pop() is Some(node) {
    if self.ordered.is_visited(node) {
      continue
    }
    self.ordered.visit(node) |> ignore
    for v in graph.neighbors(node) {
      self.degrees[v.ix] -= 1
      if self.degrees[v.ix] == 0 {
        self.tovisit.push(v)
      }
    }
    return Some(node)
  }
  None
}

///|
test "Topo::next" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  graph.add_edge(node_c, node_d) |> ignore
  let topo = Topo::new(graph)
  inspect!(topo.next(graph), content=Some(node_a).to_string())
  inspect!(topo.next(graph), content=Some(node_b).to_string())
  inspect!(topo.next(graph), content=Some(node_c).to_string())
  inspect!(topo.next(graph), content=Some(node_d).to_string())
  inspect!(topo.next(graph), content="None")
}

///|
test "Topo::next/multi" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_d) |> ignore
  graph.add_edge(node_b, node_d) |> ignore
  graph.add_edge(node_c, node_b) |> ignore
  graph.add_edge(node_c, node_a) |> ignore
  graph.add_edge(node_a, node_b) |> ignore
  let topo = Topo::new(graph)
  inspect!(topo.next(graph), content=Some(node_c).to_string())
  inspect!(topo.next(graph), content=Some(node_a).to_string())
  inspect!(topo.next(graph), content=Some(node_b).to_string())
  inspect!(topo.next(graph), content=Some(node_d).to_string())
  inspect!(topo.next(graph), content="None")
}

///|
fn get_indegree[N, E](self : Graph[N, E]) -> Array[Int] {
  let deg = Array::make(self.node_count(), 0)
  for i in 0..<self.node_count() {
    let mut edix = self.nodes[i].next.0
    while self.edges.get(edix.ix) is Some(edge) {
      deg[edge.node(1).ix] += 1
      edix = edge.next.0
    }
  }
  deg
}

///|
test "get_indegree" {
  let graph = Graph::new()
  let node_a = graph.add_node()
  let node_b = graph.add_node()
  let node_c = graph.add_node()
  let node_d = graph.add_node()
  graph.add_edge(node_a, node_b) |> ignore
  graph.add_edge(node_b, node_c) |> ignore
  graph.add_edge(node_c, node_d) |> ignore
  let indeg = get_indegree(graph)
  inspect!(indeg[node_a.ix], content="0")
  inspect!(indeg[node_b.ix], content="1")
  inspect!(indeg[node_c.ix], content="1")
  inspect!(indeg[node_d.ix], content="1")
}
