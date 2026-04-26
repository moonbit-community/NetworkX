///|
priv suberror NodeIxLimit {
  NodeIxLimit(String)
} derive(Debug)

///|
priv suberror NodeOutBounds {
  NodeOutBounds(String)
} derive(Debug)

///|
priv suberror NodeNotFound {
  NodeNotFound(String)
} derive(Debug)

///|
suberror CycleDetected {
  CycleDetected(String)
} derive(Debug)
