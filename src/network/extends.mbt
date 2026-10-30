///|
pub extend Edge with Eq::{not_equal, equal}

///|
pub extend Edge with Hash::{hash, hash_combine}

///|
pub extend Edge with Show::{to_string, output}

///|
pub extend EdgeIndex with Eq::{not_equal, equal}

///|
pub extend EdgeIndex with Hash::{hash, hash_combine}

///|
pub extend EdgeIndex with Show::{to_string, output}

///|
pub extend Graph with Show::{to_string, output}

///|
pub extend NodeIndex with Compare::{op_lt, op_le, op_ge, compare, op_gt}

///|
pub extend NodeIndex with Eq::{not_equal, equal}

///|
pub extend NodeIndex with Hash::{hash, hash_combine}

///|
pub extend NodeIndex with Show::{to_string, output}

///|
pub extend CycleDetected with Show::{to_string, output}
