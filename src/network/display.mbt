///|
fn[T : Show] display_option(value : T?) -> String {
  match value {
    None => "None"
    Some(value) => "Some(\{value})"
  }
}

///|
fn[T : Show] output_array(values : Array[T], logger : &Logger) -> Unit {
  logger.write_string("[")
  for i, value in values {
    if i > 0 {
      logger.write_string(", ")
    }
    Show::output(value, logger)
  }
  logger.write_string("]")
}

///|
pub impl Show for NodeIndex with fn output(self, logger) {
  logger.write_string("{")
  logger.write_string("ix: ")
  Show::output(self.ix, logger)
  logger.write_string("}")
}

///|
pub impl Show for EdgeIndex with fn output(self, logger) {
  logger.write_string("{")
  logger.write_string("ix: ")
  Show::output(self.ix, logger)
  logger.write_string(", from: ")
  Show::output(self.from, logger)
  logger.write_string(", successor_index: ")
  Show::output(self.successor_index, logger)
  logger.write_string("}")
}

///|
impl[N : Show] Show for Node[N] with fn output(self, logger) {
  logger.write_string("{")
  logger.write_string("ix: ")
  Show::output(self.ix, logger)
  logger.write_string(", weight: ")
  Show::output(self.weight, logger)
  logger.write_string(", next: ")
  logger.write_string("(")
  Show::output(self.next.0, logger)
  logger.write_string(", ")
  Show::output(self.next.1, logger)
  logger.write_string(")")
  logger.write_string("}")
}

///|
pub impl[E : Show] Show for Edge[E] with fn output(self, logger) {
  logger.write_string("{")
  logger.write_string("ix: ")
  Show::output(self.ix, logger)
  logger.write_string(", weight: ")
  Show::output(self.weight, logger)
  logger.write_string(", next: ")
  logger.write_string("(")
  Show::output(self.next.0, logger)
  logger.write_string(", ")
  Show::output(self.next.1, logger)
  logger.write_string(")")
  logger.write_string(", node: ")
  logger.write_string("(")
  Show::output(self.node.0, logger)
  logger.write_string(", ")
  Show::output(self.node.1, logger)
  logger.write_string(")")
  logger.write_string("}")
}

///|
pub impl[N : Show, E : Show] Show for Graph[N, E] with fn output(self, logger) {
  logger.write_string("{")
  logger.write_string("nodes: ")
  output_array(self.nodes, logger)
  logger.write_string(", edges: ")
  output_array(self.edges, logger)
  logger.write_string(", directed: ")
  Show::output(self.directed, logger)
  logger.write_string("}")
}
