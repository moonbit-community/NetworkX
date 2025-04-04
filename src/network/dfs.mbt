struct Dfs[N] {
  stack : Array[Node[N]]
  discovered : VisitMap
}

pub fn Dfs::new[N, E](g: Graph[N, E], start: Node[N]) -> Dfs[N] {
  let mp = VisitMap::new()
  mp[start.ix] = 1
  Dfs::{
    stack: [start],
    discovered: mp
  }
}

priv struct VisitMap {
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
