(** A Bit array (also known as bitmap, bitset, bit string or bit
    vector) is a specialized array data structure. *)

module Make (E : sig type t end) = struct

  type descr =
    {
      tag: string;
      mutable fields: field list;
      mutable length: int;
      mutable sealed: bool
    }
  and field =
    {
      label: string option;
      element: E.t;
      index: int;
    }
  and t =
    {
      content: Bitv.t;
      descr: descr
    }

  type elt = field

  exception Modifying_sealed_set of string

  let declare tag =
    {
      tag; fields = []; length = 0; sealed = false
    }

  let field descr ?label element =
    if descr.sealed
    then raise (Modifying_sealed_set descr.tag);

    let f =
      {
        label;
        element;
        index = descr.length;
      }
    in
    descr.fields <- f :: descr.fields;
    descr.length <- succ descr.length;
    f

  let seal descr =
    if descr.sealed
    then raise (Modifying_sealed_set descr.tag);

    descr.sealed <- true;
    descr.fields <- List.rev descr.fields;
    ()

  (** {2 Constructors and accessors for sets.}  *)

  let create descr b =
    let content = Bitv.create descr.length b in
    {
      content;
      descr
    }

  let descr t = t.descr
  let tag t = t.descr.tag
  let length t = t.descr.length

  (** {2 Accessors for fields.}  *)
  let element field = field.element
  let label field = field.label

  (** {2 Imperative operations on sets.}  *)
  let set t elt b =
    Bitv.set t.content elt.index b

  let get t elt =
    Bitv.get t.content elt.index

  let copy t =
    {content = Bitv.copy t.content; descr = t.descr}


  (** {2 Persistent operations on sets}  *)

  let add t elt =
    let content =  Bitv.copy t.content in
    Bitv.set t.content elt.index true;
    {t with content}

  let remove t elt =
    let content =  Bitv.copy t.content in
    Bitv.set t.content elt.index true;
    {t with content}

  let mem t elt =
    Bitv.get t.content elt.index

  let union a b =
    assert (a.descr == b.descr);
    {content = Bitv.bw_or a.content b.content;
     descr = a.descr}

  let inter a b =
    assert (a.descr == b.descr);
    {content = Bitv.bw_and a.content b.content;
     descr = a.descr}

  (* a \ b *)
  let diff a b =
    assert (a.descr == b.descr);
    {
      content = Bitv.bw_and a.content (Bitv.bw_not b.content);
      descr = a.descr
    }

  let complement a =
    {
      content = Bitv.bw_not a.content;
      descr = a.descr
    }


  let is_empty t =
    Bitv.all_zeros t.content

  let compare a b =
    assert (a.descr == b.descr);
    Pervasives.compare a.content b.content

  let equal a b =
    assert (a.descr == b.descr);
    a.content = b.content

  (* a \subseteq b  *)
  let subset a b =
    equal (inter a b) a

  let iter f t =
    List.iteri
      (fun i field ->
         if Bitv.get t.content i
         then f field
         else ()
      ) t.descr.fields

  let fold f t acc =
    let r = ref acc in
    List.iteri
      (fun i field ->
         if Bitv.get t.content i
         then r := f field !r
         else ()
      ) t.descr.fields;
    !r

  let count t = Bitv.pop t.content
end
