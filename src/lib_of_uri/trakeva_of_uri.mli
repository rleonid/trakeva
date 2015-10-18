(** Implementation of [Trakeva_interface.KEY_VALUE_STORE] with a
    dynamically chosen backend among the ones available at compilation time *)

(** {3 Implementation of the API}

The function [create] takes a URI string:

- if the URI scheme is ["postgresql"]
  then {!Trakeva_postgresql} will be used,
- if the URI scheme is ["sqlite"], or there is no scheme, then
  {!Trakeva_sqlite} will be used,
- an exception is raised for other schemes (reserved for future use).

*)
include Trakeva.KEY_VALUE_STORE

val available_backends : string list
(** The databases that are available via [create] *)
