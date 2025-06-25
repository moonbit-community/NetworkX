///|
fn[T] get_tuple(tuple : (T, T), index : Int) -> T {
  if index == 0 {
    return tuple.0
  }
  tuple.1
}

///|
fn[T] set_tuple(tuple : (T, T), index : Int, value : T) -> (T, T) {
  if index == 0 {
    return (value, tuple.1)
  }
  (tuple.0, value)
}

// fn swap_remove[T](a : Array[T], index : Int) -> T? {
//     let last_index = a.length() - 1
//     guard index >= 0 && index <= last_index else {
//         return None
//     }
//     if index != last_index {
//         a.swap(index, last_index)
//     }
//     Some(a.remove(last_index))
// }
