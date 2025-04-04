///|
struct Dfs {
  stack : Array[NodeIndex]
  discovered : VisitMap
}

///|
pub fn Dfs::new[N, E](g : Graph[N, E], start : NodeIndex) -> Dfs {
  Dfs::{ stack: [start], discovered: VisitMap::new() }
}

///|
struct VisitMap {
  visit : @hashmap.T[NodeIndex, Bool]
}

///|
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
trait VM {
  visit(Self, NodeIndex) -> Bool
  is_visited(Self, NodeIndex) -> Bool
  unvisit(Self, NodeIndex) -> Bool
}

///|
pub fn Dfs::empty() -> Dfs {
  Dfs::{ stack: [], discovered: VisitMap::new() }
}

///|
pub fn Dfs::from_parts(
  stack : Array[NodeIndex],
  discovered : VisitMap
) -> Dfs {
  Dfs::{ stack, discovered }
}

///|
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

///|
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
  inspect!(dfs.next(graph), content="Some({ix: 0})")
  inspect!(dfs.next(graph), content="Some({ix: 1})")
  inspect!(dfs.next(graph), content="Some({ix: 2})")
  inspect!(dfs.next(graph), content="Some({ix: 3})")
  inspect!(dfs.next(graph), content="None")
  // empty the stack
  inspect!(dfs.next(graph), content="None")
}
