(* OASIS_START *)
(* OASIS_STOP *)
# 4 "myocamlbuild.ml"
open Ocamlbuild_plugin
open Printf

let env = BaseEnvLight.load() (* setup.data *)

let is_enabled key =
  try bool_of_string (BaseEnvLight.var_get key env)
  with _ -> false

let () =
  let additional_rules = function
    | After_rules ->
        (*let uripn = [ "src/lib_of_uri/trakeva_of_uri.cmo"
                    ; "src/lib_of_uri/trakeva_of_uri.cma"
        ] in *)
        let available_backends = ref [] in
        let dir_ref = ref [] in
        let if_enabled k v dir =
          if is_enabled k then begin
            dir_ref := A "-I" :: A dir :: !dir_ref;
            available_backends := k :: !available_backends;
            let l = String.lowercase v in
            (*let t = dir / (l ^ ".ml") in
            let ts = tags_of_pathname t |> Tags.elements in
            let ts = ListLabels.filter ~f:(fun s ->
              let se = String.sub s 0 4 in
              se = "pkg_") ts
            in
            let tags_to_add = (*"use_" ^ l) ::*) ts in
            List.iter (fun p -> tag_file p tags_to_add) uripn;*)
            use_lib "trakeva_of_uri" l;
            v
          end else
            "Trakeva_missing"
        in
        let postgresql =
          if_enabled "postgresql" "Trakeva_postgresql" "src/lib_postgresql"
        in
        let sqlite = if_enabled "sqlite" "Trakeva_sqlite" "src/lib_sqlite" in
        let available_backends =
          List.map (sprintf "%S") !available_backends
          |> String.concat ";"
          |> sprintf "[%s]"
        in
        rule "assignments file"
          ~prod:"src/lib_of_uri/assignments.ml"
          ~doc:"Generate module assignments based upon enabled backends"
          (fun _env _build ->
            flag ["ocaml"; "compile";] (S !dir_ref);
            flag ["ocaml"; "link"; ] (S !dir_ref);
            let code = sprintf
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
      [ MyOCamlbuildBase.dispatch_default conf package_default
      ; additional_rules
      ])
