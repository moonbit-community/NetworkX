///|
struct Lca[N, E] {
  graph : Graph[N, E]
  deep : Array[Int]
  father : Array[Array[Int]]
  mut root : NodeIndex
}

///| dfs0
fn Lca::update_lca_info_pre[N, E](
  self : Lca[N, E],
  graph : Graph[N, E],
  u : NodeIndex,
  f : NodeIndex,
  d : Int
) -> Unit {
  self.deep[u.ix] = d
  for v in graph.neighbors(u) {
    if v != f {
      self.father[v.ix][0] = u.ix
      self.update_lca_info_pre(graph, v, u, d + 1)
    }
  }
}

///|
fn Lca::update_lca_info[N, E](
  self : Lca[N, E],
  graph : Graph[N, E],
  u : NodeIndex,
  f : NodeIndex,
  d : Int
) -> Unit {
  let n = self.graph.node_count()
  let top = @math.log2((n + 1).to_double()).to_int()
  self.update_lca_info_pre(graph, u, f, d)
  for j in 1..=top {
    for i in 1..=n {
      self.father[i][j] = self.father[self.father[i][j - 1]][j - 1]
    }
  }
}

///| Create a new Lowest Common Ancestor (LCA) instance
///
/// Parameters
///
/// - `graph` : The graph on which the LCA computation will be performed, represented as a `Graph[N, E]`.
/// - `root` : The root node for the LCA computation, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Lca[N, E]` : A new LCA instance initialized with the graph and root node.
/// 
/// Errors
///
/// - `CycleDetected` : Raised if the input graph contains a cycle.
///
/// Example
/// ```
/// let lca = Lca::new!(graph, root)
/// ```
pub fn Lca::new[N, E](
  graph : Graph[N, E],
  root : NodeIndex
) -> Lca[N, E]!CycleDetected {
  guard graph.is_cyclic() == false else {
    raise CycleDetected("There is a cycle in the graph")
  }
  let n = graph.node_count()
  let deep = Array::make(n + 1, 0)
  let top = @math.log2((n + 1).to_double()).to_int()
  let father = Array::makei(n + 1, fn(_) { Array::make(top + 1, 0) })
  let lca = Lca::{ graph, deep, father, root }
  lca.update_lca_info(lca.graph, lca.root, NodeIndex::new(-1), 1)
  lca
}

///| Query the Lowest Common Ancestor (LCA) of two nodes in the graph
///
/// Parameters
///
/// - `u` : The first node, represented as a `NodeIndex`.
/// - `v` : The second node, represented as a `NodeIndex`.
///
/// Returns
///
/// - `NodeIndex` : The Lowest Common Ancestor of the two nodes.
///
/// Example
/// ```
/// let ancestor = lca.query(node_a, node_b)
/// ```
pub fn Lca::query[N, E](
  self : Lca[N, E],
  u : NodeIndex,
  v : NodeIndex
) -> NodeIndex {
  let mut u = u.ix
  let mut v = v.ix
  if self.deep[u] < self.deep[v] {
    let temp = u
    u = v
    v = temp
  }
  let n = self.graph.node_count()
  let top = @math.log2((n + 1).to_double()).to_int()
  for i = top; i >= 0; i = i - 1 {
    if self.deep[self.father[u][i]] >= self.deep[v] {
      u = self.father[u][i]
    }
  }
  if u == v {
    return NodeIndex::new(u)
  }
  for i = top; i >= 0; i = i - 1 {
    if self.father[u][i] != self.father[v][i] {
      u = self.father[u][i]
      v = self.father[v][i]
    }
  }
  NodeIndex::new(self.father[u][0])
}

///| Reset the Lowest Common Ancestor (LCA) instance
///
/// Parameters
///
/// - `root?` : (Optional) The new root node for the LCA computation, represented as a `NodeIndex`.
///
/// Returns
///
/// - `Unit` : This function updates the LCA instance in place.
///
/// Example
/// ```
/// lca.reset()
/// lca.reset(new_root)
/// ```
pub fn Lca::reset[N, E](self : Lca[N, E], root? : NodeIndex) -> Unit {
  if root is Some(r) {
    self.root = r
  }
  self.update_lca_info(self.graph, self.root, NodeIndex::new(-1), 1)
}

///|
test "Lca::query/undir1" {
  let graph = Graph::new(directed=false)
  let a = graph.add_node()
  let b = graph.add_node()
  graph.add_edge(a, b) |> ignore
  let lca = Lca::new!(graph, a)
  inspect!(lca.query(a, b), content=a.to_string())
  inspect!(lca.query(b, a), content=a.to_string())
  inspect!(lca.query(a, a), content=a.to_string())
  inspect!(lca.query(b, b), content=b.to_string())
}

///|
test "Lca::query/undir2" {
  let graph = Graph::new(directed=false)
  let a = graph.add_node()
  let b = graph.add_node()
  let c = graph.add_node()
  let d = graph.add_node()
  graph.add_edge(a, b) |> ignore
  graph.add_edge(b, c) |> ignore
  graph.add_edge(c, d) |> ignore
  let lca = Lca::new!(graph, a)
  inspect!(lca.query(b, d), content=b.to_string())
  inspect!(lca.query(c, d), content=c.to_string())
  inspect!(lca.query(a, d), content=a.to_string())
  inspect!(lca.query(a, c), content=a.to_string())
}

///|
test "Lca::query/undir3" {
  let graph = Graph::new(directed=false)
  let a = graph.add_node()
  let b = graph.add_node()
  let c = graph.add_node()
  let d = graph.add_node()
  let e = graph.add_node()
  graph.add_edge(a, b) |> ignore
  graph.add_edge(b, c) |> ignore
  graph.add_edge(a, d) |> ignore
  graph.add_edge(d, e) |> ignore
  let lca = Lca::new!(graph, a)
  inspect!(lca.query(c, e), content=a.to_string())
  inspect!(lca.query(c, d), content=a.to_string())
  inspect!(lca.query(b, e), content=a.to_string())
  inspect!(lca.query(b, d), content=a.to_string())
  inspect!(lca.query(c, b), content=b.to_string())
  inspect!(lca.query(a, c), content=a.to_string())
}

///|
test "Lca::query/dir" {
  let graph = Graph::new(directed=true)
  let a = graph.add_node()
  let b = graph.add_node()
  let c = graph.add_node()
  let d = graph.add_node()
  let e = graph.add_node()
  graph.add_edge(a, b) |> ignore
  graph.add_edge(b, c) |> ignore
  graph.add_edge(a, d) |> ignore
  graph.add_edge(d, e) |> ignore
  let lca = Lca::new!(graph, a)
  inspect!(lca.query(c, e), content=a.to_string())
  inspect!(lca.query(c, d), content=a.to_string())
  inspect!(lca.query(b, e), content=a.to_string())
  inspect!(lca.query(b, d), content=a.to_string())
  inspect!(lca.query(c, b), content=b.to_string())
}
