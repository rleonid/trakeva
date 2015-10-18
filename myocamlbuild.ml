(* OASIS_START *)
(* OASIS_STOP *)
# 4 "myocamlbuild.ml"
open Ocamlbuild_plugin

let env = BaseEnvLight.load() (* setup.data *)

let is_enabled key =
  try bool_of_string (BaseEnvLight.var_get key env)
  with _ -> false

let () =
  let additional_rules = function
    | After_rules ->
        rule "assignments file"
          ~prod:"src/lib_of_uri/assignments.ml"
          ~doc:"Generate module assignments based upon enabled backends"
          (fun _env _build ->
            let available_backends = ref [] in
            let if_enabled k v dir =
              if is_enabled k then begin
                flag ["ocaml"; "compile";]  (S [A "-I"; A dir]);
                flag ["ocaml"; "link"; ]    (S [A "-I"; A dir]);
                available_backends := k :: !available_backends;
                v
              end else
                "Trakeva_missing"
            in
            let sqlite = if_enabled "sqlite" "Trakeva_sqlite" "src/lib_sqlite" in
            let postgresql = if_enabled "postgresql" "Trakeva_postgresql" "src/lib_postgresql" in 
            let available_backends =
              List.map (Printf.sprintf "%S") !available_backends
              |> String.concat ";"
              |> Printf.sprintf "[%s]"
            in
            let code = Printf.sprintf
              "module Sqlite = %s\n\
               module Postgresql = %s\n\
               let available_backends = %s\n"
               sqlite postgresql available_backends
            in
            Echo ([code], "src/lib_of_uri/assignments.ml"))
    | _ -> ()
  in
  dispatch
    (MyOCamlbuildBase.dispatch_combine
      [MyOCamlbuildBase.dispatch_default conf package_default;
      additional_rules])
