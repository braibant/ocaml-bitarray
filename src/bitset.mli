module Make (E : sig type t end) : sig

  (** The type of set descriptors. The type variable ['universe] is
      non-generalisable, and is here to prevent the user for
      mismatching elements.  *)
  type 'universe descr


  (** The type of asbtract elements of the set. This type is
      parameterised by ['universe] to prevent mismatching handles. *)
  type 'universe element

  (** The type of concrete sets that belong to the ['universe]
      universe. *)
  type 'universe t

  (** {2 Declaring a new set.}  *)

  (** [declare tag] declare a new set universe with name [tag]. This
      [tag] is only used for debug purpose and to raise more
      meaningful errors.  *)
  val declare : string -> 'universe descr
  val element: 'universe descr -> ?label:string -> E.t -> 'universe element
  val seal: 'universe descr -> unit

  val tag: 'universe descr -> string
  val size: 'universe descr -> int

  (** {2 Constructors and accessors for concrete sets.}  *)
  val create: 'universe descr -> bool -> 'universe t
  val descr: 'universe t -> 'universe descr
  val cardinal: 'universe t -> int
  val elements: 'universe t -> E.t list

  (** {2 Accessors for set elements.}  *)

  (** The type of the two following functions raises an interesting
      issue.
      We might want to give them the following types:
      ```
      val element: 'universe element -> E.t
      val label: 'universe element -> string option
      ```

      In practice, the signature below forces each element to store a
      pointer to the set descriptor, hence wasting one word per
      element handle. By contrast, if we require an extra ['universe
      descr] argument, each ['a element] can be implemented as
      an unboxed integer. *)

  val element: 'universe descr -> 'universe element -> E.t
  val label: 'universe descr -> 'universe element -> string option

  (** {2 Imperative operations on sets.}  *)
  val set: 'universe t -> 'universe element -> bool -> unit
  val get: 'universe t -> 'universe element -> bool
  val copy: 'universe t -> 'universe t

  (** {2 Persistent operations on sets}  *)
  val add: 'universe t -> 'universe element -> 'universe t
  val remove: 'universe t -> 'universe element -> 'universe t
  val mem: 'universe t -> 'universe element -> bool

  val union: 'universe t -> 'universe t -> 'universe t
  val inter: 'universe t -> 'universe t -> 'universe t
  val diff : 'universe t -> 'universe t -> 'universe t
  val complement: 'universe t -> 'universe t

  val is_empty: 'universe t -> bool
  val compare: 'universe t -> 'universe t -> int
  val equal: 'universe t -> 'universe t -> bool
  val subset: 'universe t -> 'universe t -> bool

  (** {2 Higher-order iterators}  *)
  val iter: (E.t -> unit) -> 'universe t -> unit
  val fold: (E.t -> 'a -> 'a) -> 'universe t -> 'a -> 'a

  (** Population count, i.e., number of elements.  *)
end
