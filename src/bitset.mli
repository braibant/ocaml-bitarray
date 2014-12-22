(** A Bit array (also known as bitmap, bitset, bit string or bit
    vector) is a specialized array data structure. At its core, a
    bit array is an array of bits (hence the name). A bit array can
    typically be used to encode sets of elements in a compact
    fashion (using one bit per element), but it requires the user to
    keep track of the data encoded by each bit.

    As an example, consider the following data type that denotes a
    type with 5 elements.

    ```
    type t = | A | B | C | D of bool
    ```

    There are 2^5 possible sets of elements of `t` and they can can
    easily be encoded by integer values (or even single
    bytes!). However, to leverage that compact representation the user
    must write boilerplate code that, e.g., map each value of the type
    t to the corresponding singleton (written as an integer), and it's
    converse.

    Such a function might look like:
    ```
    let to_int = function
    | A -> 1 lsl 0                      (* 1 *)
    | B -> 1 lsl 1                      (* 2 *)
    | C -> 1 lsl 2                      (* 4 *)
    | D true -> 1 lsl 3                 (* 8 *)
    | D false -> 1 lsl 4                (* 16 *)
    ```

    Then the user must write the reverse function which is
    error-prone, and tedious.

    The goal of this module is to abstract this kind of code away. The
    user must explicitly declare each *set universe* she wants to use
    by declaring each one of the value that might belong to a set in
    this universe. Each registered value is associated to a
    *handle*. Then, the user can use these handles to build sets of
    values. We use the type system to prevent the user to mismatch
    handles: an handle for a universe X cannot be used as an handle
    for a universe Y.
*)

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
