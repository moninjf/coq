(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(* We register this handler for lower-level toplevel loading code *)
let _ = CErrors.register_handler (function
    | Symtable.Error e ->
      Some (Pp.str (Format.asprintf "%a" Symtable.report_error e))
    | _ ->
      None
  )

(* XXX: Remove this for Toploop.get_directive once we bump the OCaml
   version, unfortunately 4.05 still doesn't have it, and 4.13
   deprecated directive_table *)
let _get_directive name =
  let dt = Toploop.directive_table [@ocaml.warning "-3"] in
  Hashtbl.find_opt dt name

(* XXX: 4.13 deprecated Topdirs.load_file in favor of
   Toopload.load_file, however that last function was introduced in
   4.12 so it seems... *)
let _load_file = Topdirs.load_file [@ocaml.warning "-3"]

let drop_setup () =
  begin
    (* Enable rectypes in the toplevel if it has the directive #rectypes *)
    match _get_directive "rectypes" with
    | None -> ()
    | Some (Toploop.Directive_none f) -> f ()
    | Some _ ->
      Format.eprintf "Warning: rectypes directive has changed!!@\n%!"
  end;
  let ppf = Format.std_formatter in
  Mltop.(set_top
           { load_obj = (fun f -> if not (_load_file ppf f)
                          then CErrors.user_err Pp.(str ("Could not load plugin "^f))
                        );
             add_dir  = Topdirs.dir_directory;
             ml_loop  = (fun () -> Toploop.loop ppf);
           })

(* Main coqtop initialization *)
let _ =
  drop_setup ();
  Coqtop.(start_coq coqtop_toplevel)
