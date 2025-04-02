struct NodeIndex {
  ix : Int
}
struct EdgeIndex {
  ix : Int
  from : NodeIndex
  successor_index : UInt
}
struct Node[N] {
  ix : NodeIndex
  weight : N
  next : (EdgeIndex, EdgeIndex)
}

struct Edge[E] {
  ix : EdgeIndex
  weight : E
  next : EdgeIndex
  node : (NodeIndex, NodeIndex)
}

struct Graph[N, E] {
  nodes : Array[Node[N]]
  edges : Array[Edge[E]]
  directed : Bool
}

// struct Graph[T]{
//   matrix : @hashmap.T[T, Array[T]];
//   directed : Bool
// } derive(Show)

// ///|
// pub fn Graph::from_hashmap[T:Compare+Hash](edges : @hashmap.T[T, Array[T]], directed : Bool) -> Graph[T] {
//   let matrix: @hashmap.T[T, Array[T]] = match directed {
//     false => {
//       let mp = @hashmap.new()
//       for e in edges {
//         let u = e.0
//         for v in e.1 {
//           match mp[u] {
//             None => mp[u] = [v]
//             Some(l) if not(l.contains(v)) => l.push(v)
//             _ => ()
//           }
//           match mp[v] {
//             None => mp[v] = [u]
//             Some(l) if not(l.contains(u)) => l.push(u)
//             _ => ()
//           }
//         }
//       }
//       mp
//     }
//     true => edges
//   }
//   Graph::{
//     matrix,
//     directed
//   }
// }

// ///|
// test "Graph::from_hashmap" {
//   let mp: @hashmap.T[Int, Array[Int]] = @hashmap.of([(1, [2]), (2, [3])])
//   let g = Graph::from_hashmap(mp, false)
//   inspect!(g, content="{matrix: HashMap::of([(2, [3, 1]), (1, [2]), (3, [2])]), directed: false}")
//   let g2 = Graph::from_hashmap(mp, true)
//   inspect!(g2, content="{matrix: HashMap::of([(2, [3]), (1, [2])]), directed: true}")
// }

// ///|
// pub fn Graph::add_edge[T: Hash+Eq](self : Graph[T], u : T, v : T) -> Unit {
//   match self.matrix[u] {
//     None => self.matrix[u] = [v]
//     Some(l) if not(l.contains(v)) => l.push(v)
//     _ => ()
//   }
//   if not(self.directed) {
//     match self.matrix[v] {
//       None => self.matrix[v] = [u]
//       Some(l) if not(l.contains(u)) => l.push(u)
//       _ => ()
//     }
//   }
// }

// ///|
// test "Graph::add_edge" {
//   let mp: @hashmap.T[Int, Array[Int]] = @hashmap.of([(1, [2])])
//   let g = Graph::from_hashmap(mp, true)
//   g.add_edge(2, 3)
//   inspect!(g, content="{matrix: HashMap::of([(2, [3]), (1, [2])]), directed: true}")
//   let g2 = Graph::from_hashmap(mp, false)
//   g2.add_edge(2, 3)
//   inspect!(g2, content="{matrix: HashMap::of([(2, [3, 1]), (1, [2]), (3, [2])]), directed: false}")
// }

// ///|
// pub fn Graph::dijkstra[T: Hash+Eq](self : Graph[T], start : T) -> @hashmap.T[T, Int] {
//   ...
// }