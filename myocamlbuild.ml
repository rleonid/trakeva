(* OASIS_START *)
(* OASIS_STOP *)
# 1 "myocamlbuild.ml"
open Ocamlbuild_plugin

let env = BaseEnvLight.load() (* setup.data *)

let is_enabled key =
  try bool_of_string (BaseEnvLight.var_get key env)
  with _ -> false

let () =
  let additional_rules = function
    | After_rules ->
        let s, i =
          if is_enabled "sqlite" then
            ([A"-e s/ReplaceWithSqliteModule/Trakeva_sqlite/"]),
            (A"-I" :: A "src/lib_sqlite" :: [])
          else
            ([], [])
        in
        let s, i =
          if is_enabled "postgresql" then
            (A"-e s/ReplaceWithPostgresqModule/Trakeva_postgresql/" :: s),
            (A"-I" :: A "src/lib_postgresql" :: i)
          else
            s, i
        in
        begin match s, i with
        | [], [] ->  ()
        | s, i ->
            flag ["pp"; "replace_module"]       (S (A"sed"::s));
            flag ["compile"; "replace_module"]  (S i);
            flag ["link"; "replace_module"]     (S i);
          end

    | _ -> ()
  in
  dispatch
    (MyOCamlbuildBase.dispatch_combine
      [MyOCamlbuildBase.dispatch_default conf package_default;
      additional_rules])
