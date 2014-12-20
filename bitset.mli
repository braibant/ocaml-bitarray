(** A Bit array (also known as bitmap, bitset, bit string or bit
    vector) is a specialized array data structure. *)

module Make (E : sig type t end) : sig

  (** The type of elements of the set. *)
  type elt

  (** The type of set descriptors.  *)
  type descr

  (** The type of sets. *)
  type t

  (** {2 Declaring a new set.}  *)

  val declare : string -> descr
  val field: descr -> ?label:string -> E.t -> elt
  val seal: descr -> unit

  (** {2 Constructors and accessors for sets.}  *)
  val create: descr -> bool -> t
  val descr: t -> descr
  val tag: t -> string
  val length: t -> int

  (** {2 Accessors for fields.}  *)
  val element: elt -> E.t
  val label: elt -> string option

  (** {2 Imperative operations on sets.}  *)
  val set: t -> elt -> bool -> unit
  val get: t -> elt -> bool
  val copy: t -> t

  (** {2 Persistent operations on sets}  *)
  val add: t -> elt -> t
  val remove: t -> elt -> t
  val mem: t -> elt -> bool

  val union: t -> t -> t
  val inter: t -> t -> t
  val diff : t -> t -> t
  val complement: t -> t

  val is_empty: t -> bool
  val compare: t -> t -> int
  val equal: t -> t -> bool
  val subset: t -> t -> bool
  val iter: (elt -> unit) -> t -> unit
  val fold:(elt -> 'a -> 'a) -> t -> 'a -> 'a

  (** Population count, i.e., number of elements.  *)
  val count:
  (* singleton: elt -> t cannot be implemented without wasting 1 word per field descriptor. *)
end
