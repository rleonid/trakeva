(* OASIS_START *)
(* OASIS_STOP *)
# 4 "myocamlbuild.ml"
open Ocamlbuild_plugin

let env = BaseEnvLight.load() (* setup.data *)

let is_enabled key =
  try bool_of_string (BaseEnvLight.var_get key env)
  with _ -> false

let add_if_enabled key ~sed ~idir (s, i) =
  if is_enabled key then
    (A ("-e "^sed) :: s),
    (A "-I" :: A idir :: i)
  else
    (s,i)

let () =
  let additional_rules = function
    | After_rules ->
        ([], [])
        |> add_if_enabled "sqlite"
            ~sed:"s/ReplaceWithSqliteModule/Trakeva_sqlite/"
            ~idir:"src/lib_sqlite"
        |> add_if_enabled "postgresql"
            ~sed:"s/ReplaceWithPostgresqModule/Trakeva_postgresql/"
            ~idir:"src/lib_postgresql"
        |> begin
             function
             | [], [] ->
                 mark_tag_used "replace_module"
             | (s, i) ->
                 flag ["pp"; "replace_module"]                (S (A "sed":: s));
                 flag ["ocaml"; "compile"; "replace_module"]  (S i);
                 flag ["ocaml"; "link"; "replace_module"]     (S i);
                 (*tag_file "src/lib_of_uri/trakeva_of_uri.ml"  ["use_trakeva_postgresql"];
                 tag_file "src/lib_of_uri/trakeva_of_uri.mli" ["use_trakeva_postgresql"];
                 tag_file "src/lib_of_uri/trakeva_of_uri.cmi" ["use_trakeva_postgresql"];
                 tag_file "src/lib_of_uri/trakeva_of_uri.cmo" ["use_trakeva_postgresql"];
                 tag_file "src/lib_of_uri/trakeva_of_uri.cma" ["use_trakeva_postgresql"];
                 tag_file "src/lib_of_uri/trakeva_of_uri.cmx" ["use_trakeva_postgresql"]  *)

        end;
        ()

    | _ -> ()
  in
  dispatch
    (MyOCamlbuildBase.dispatch_combine
      [MyOCamlbuildBase.dispatch_default conf package_default;
      additional_rules])
