struct Dfs[N] {
  stack : Array[Node[N]]
  discovered : VisitMap
}

pub fn Dfs::new[N, E](g: Graph[N, E], start: Node[N]) -> Dfs[N] {
  Dfs::{
    stack: [start],
    discovered: VisitMap::new()
  }
}

struct VisitMap {
  visit : @hashmap.T[NodeIndex, Int]
}

fn VisitMap::new() -> VisitMap {
  VisitMap::{
    visit: @hashmap.new()
  }
}

fn VisitMap::op_set(self: VisitMap, node: NodeIndex, count: Int) -> Unit {
  self.visit[node] = count
}

fn VisitMap::op_get(self: VisitMap, node: NodeIndex) -> Int {
  match self.visit.get(node) {
    Some(t) => t
    None => 0
  }
}

impl VM for VisitMap with visit(self, node: NodeIndex) -> Bool {
  self.visit.contains(node)
}

impl VM for VisitMap with is_visited(self, node: NodeIndex) -> Bool {
  match self.visit.get(node) {
    Some(t) if t >= 2 => true
    _ => false
  }
}

impl VM for VisitMap with unvisit(self, node: NodeIndex) -> Bool {
  not(self.visit.contains(node))
}
trait VM {
  visit(Self, NodeIndex) -> Bool
  is_visited(Self, NodeIndex) -> Bool
  unvisit(Self, NodeIndex) -> Bool
}

///|
pub fn Dfs::empty[N]() -> Dfs[N] {
  Dfs::{
    stack: [],
    discovered: VisitMap::new()
  }
}

///|
pub fn Dfs::from_parts[N](stack: Array[Node[N]], discovered: VisitMap) -> Dfs[N] {
  Dfs::{
    stack: stack,
    discovered: discovered
  }
}

///|
pub fn Dfs::reset[N](self: Dfs[N]) -> Unit {
  self.stack.clear()
  self.discovered.visit.clear()
}

/// Keep the discovered map, but clear the visit stack and
/// restart the dfs from a particular node.
pub fn Dfs::move_to[N](self: Dfs[N], node: Node[N]) -> Unit {
  self.stack.clear()
  self.stack.push(node);
}

pub fn Dfs::next[N, E](self: Dfs[N], g: Graph[N, E]) -> Option[Node[N]] {
  ...
}