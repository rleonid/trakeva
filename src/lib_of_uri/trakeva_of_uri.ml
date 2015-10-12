
open Pvem_lwt_unix
open Pvem_lwt_unix.Deferred_result

module Trakeva_missing : Trakeva.KEY_VALUE_STORE = struct
   type t
   let load s =
     Printf.ksprintf failwith "No trakeva backend can understand: %S" s
   let get ?collection t ~key = assert false
   let get_all _ = assert false
   let act _ = assert false
   let iterator _ = assert false
   let close _ = assert false
end

module Sqlite = ReplaceWithSqliteModule
module Postgresql = ReplaceWithPostgresqModule
(*module Sqlite = Trakeva_sqlite
module Postgresql = Trakeva_postgresql *)
type t = {
  implementation: (module Trakeva.KEY_VALUE_STORE with type t = t);
}
let load s =
  let uri = Uri.of_string s in
  let backend, load_parameters =
     match Uri.scheme uri with
     | Some "postgresql" -> ((module Postgresql : Trakeva.KEY_VALUE_STORE), s)
     | Some "sqlite" | None ->
       ((module Sqlite : Trakeva.KEY_VALUE_STORE), Uri.path uri)
     | Some other ->
       Printf.ksprintf failwith "Can't recognize URI scheme: %S" other
   in
   let module KV = (val backend) in
   KV.load load_parameters
   >>= fun backend_handle ->
   let module Implementation = struct
     type i = t
     type t = i
     let load _ = assert false
     let get ?collection t ~key = KV.get ?collection backend_handle ~key
     let close t = KV.close backend_handle
     let get_all _ ~collection = KV.get_all backend_handle ~collection
     let iterator _ ~collection = KV.iterator backend_handle ~collection
     let act _ ~action = KV.act backend_handle ~action
   end in
   return {implementation = (module Implementation)}

let get ?collection t ~key = 
  let module KV = (val t.implementation) in
  KV.get ?collection t ~key
let close t = 
  let module KV = (val t.implementation) in
  KV.close t
let get_all t ~collection = 
  let module KV = (val t.implementation) in
  KV.get_all t ~collection
let iterator t ~collection = 
  let module KV = (val t.implementation) in
  KV.iterator t ~collection
let act t ~action = 
  let module KV = (val t.implementation) in
  KV.act t ~action

