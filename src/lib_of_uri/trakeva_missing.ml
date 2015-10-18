(** Assign this module if an implementation of a URI is missing *)

type t
let load s =
  Printf.ksprintf failwith "No trakeva backend can understand: %S" s
let get ?collection t ~key = assert false
let get_all _ = assert false
let act _ = assert false
let iterator _ = assert false
let close _ = assert false
