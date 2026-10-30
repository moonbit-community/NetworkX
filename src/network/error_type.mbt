///|
priv suberror NodeIxLimit {
  NodeIxLimit(String)
} derive(Show)

///|
priv suberror NodeOutBounds {
  NodeOutBounds(String)
} derive(Show)

///|
priv suberror NodeNotFound {
  NodeNotFound(String)
} derive(Show)

///|
suberror CycleDetected {
  CycleDetected(String)
} derive(Show)
