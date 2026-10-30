///|
priv suberror NodeIxLimit {
  NodeIxLimit(String)
}

///|
priv suberror NodeOutBounds {
  NodeOutBounds(String)
}

///|
priv suberror NodeNotFound {
  NodeNotFound(String)
}

///|
suberror CycleDetected {
  CycleDetected(String)
}

///|
impl Show for NodeIxLimit with fn output(self, logger) {
  let NodeIxLimit(message) = self
  logger.write_string("NodeIxLimit(")
  Show::output(message, logger)
  logger.write_string(")")
}

///|
impl Show for NodeOutBounds with fn output(self, logger) {
  let NodeOutBounds(message) = self
  logger.write_string("NodeOutBounds(")
  Show::output(message, logger)
  logger.write_string(")")
}

///|
impl Show for NodeNotFound with fn output(self, logger) {
  let NodeNotFound(message) = self
  logger.write_string("NodeNotFound(")
  Show::output(message, logger)
  logger.write_string(")")
}

///|
pub impl Show for CycleDetected with fn output(self, logger) {
  let CycleDetected(message) = self
  logger.write_string("CycleDetected(")
  Show::output(message, logger)
  logger.write_string(")")
}
