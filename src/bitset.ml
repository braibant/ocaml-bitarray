(** A Bit array (also known as bitmap, bitset, bit string or bit
    vector) is a specialized array data structure. *)
module Make (E : sig type t end) = struct

  (* There is a balance to stike between having more information in
     the ['a element] type -- the actual value, the index in the
     bitset and the label -- or more information in the ['a descr].

     As an implementation choice, we choose to have less information
     in the ['a elements] and more in the ['a descr]. We allocate one
     array for element' labels, one for element contents in ['a descr].

*)
  type 'a descr =
      {
        tag: string;
        mutable sealed: bool;

        (* we ensure the following invariant:
           - Array.length labels = Array.length contents
           - if sealed
             then Array.length labels = size
             else size <= Array.length labels
        *)
        mutable labels: string option array;
        mutable contents: E.t array;
        mutable size: int;
      }
  and 'a element = int
  and 'a t =
      {
        content: Bitv.t;
        descr: 'a descr
      }

  exception Modifying_sealed_set of string

  let declare tag =
    {
      tag;
      sealed = false;
      labels = [||];
      contents = [||];
      size = 0;
    }

  let element descr ?label element =
    if descr.sealed
    then raise (Modifying_sealed_set descr.tag);

    if descr.size < Array.length descr.contents
    then
      begin
        let size = descr.size in
        descr.contents.(size) <- element;
        descr.labels.(size) <- label;
        descr.size <- size + 1;
        size
      end
    else
      begin
        let size = descr.size in
        assert (size = Array.length descr.contents);
        let n = max 64 (2 * size) in
        (* allocate new storage *)
        let contents = Array.make n element in
        let labels = Array.make n label in
        (* copy existing values into the new storage *)
        Array.blit descr.contents 0 contents 0 size;
        Array.blit descr.labels   0 labels 0 size;
        (* update descr *)
        descr.contents <- contents;
        descr.labels <- labels;
        descr.size <- size + 1;
        size
      end

  let seal descr =
    if descr.sealed
    then raise (Modifying_sealed_set descr.tag);

    descr.sealed <- true;
    descr.contents <- Array.sub descr.contents 0 descr.size;
    descr.labels <- Array.sub descr.labels 0 descr.size;
    ()

  let tag descr = descr.tag
  let size descr = descr.size

  (** {2 Constructors and accessors for sets.}  *)

  let create descr b =
    let content = Bitv.create descr.size b in
    {
      content;
      descr
    }

  let descr t = t.descr
  let cardinal t =
    let r = ref 0 in
    Bitv.iteri_true (fun _ -> incr r) t.content;
    !r

  let elements t =
    let r = ref [] in
    let contents = t.descr.contents in
    Bitv.iteri_true (fun i -> r := contents.(i) :: !r) t.content;
    List.rev !r

  (** {2 Accessors for fields.} *)
  let element descr field = descr.contents.(field)
  let label descr field = descr.labels.(field)

  (** {2 Imperative operations on sets.}  *)
  let set t elt b =
    Bitv.set t.content elt b

  let get t elt =
    Bitv.get t.content elt

  let copy t =
    {content = Bitv.copy t.content; descr = t.descr}


  (** {2 Persistent operations on sets}  *)

  let add t elt =
    let content =  Bitv.copy t.content in
    Bitv.set t.content elt true;
    {t with content}

  let remove t elt =
    let content =  Bitv.copy t.content in
    Bitv.set t.content elt true;
    {t with content}

  let mem t elt =
    Bitv.get t.content elt

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
    let contents = t.descr.contents in
    Bitv.iteri_true (fun i -> f contents.(i)) t.content

  let fold f t acc =
    let r = ref acc in
    let contents = t.descr.contents in
    Bitv.iteri_true (fun i -> r := f contents.(i) !r) t.content;
    !r

  external element_of_int  : int -> 'universe element = "%identity"
  external int_of_element  : 'universe element -> int = "%identity"
end
