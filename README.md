# Description

A Bit array (also known as bitmap, bitset, bit string or bit vector)
is a specialized array data structure. At its core, a bit array is an
array of bits (hence the name). A bit array can typically be used to
encode sets of elements in a compact fashion (using one bit per
element), but it requires the user to keep track of the data encoded
by each bit.

As an example, consider the following data type that denotes a type
with 5 elements.

```
type t = | A | B | C | D of bool
```

There are 2^5 possible sets of elements of `t` and they can can easily
be encoded by integer values (or even single bytes!). However, to
leverage that compact representation the user must write boilerplate
code that, e.g., map each value of the type t to the corresponding
singleton (written as an integer), and it's converse.

Such a function might look like:

```
let to_int = function
| A -> 1 lsl 0                      (* 1 *)
| B -> 1 lsl 1                      (* 2 *)
| C -> 1 lsl 2                      (* 4 *)
| D true -> 1 lsl 3                 (* 8 *)
| D false -> 1 lsl 4                (* 16 *)
```

Then the user must write the reverse function which is error-prone,
and tedious.

The goal of this module is to abstract this kind of code away. The
user must explicitly declare each *set universe* she wants to use by
declaring each one of the value that might belong to a set in this
universe. Each registered value is associated to a *handle*. Then, the
user can use these handles to build sets of values. We use the type
system to prevent the user to mismatch handles: an handle for a
universe X cannot be used as an handle for a universe Y.

# Disclaimer

This library is a rather thin wrapper around the `bitv`, by
J.-C. Filliatre. The wrapper makes it possible to abstract some of the
boilerplate code that a user often needs to write. It also highjack
the type checker to prevent the user from mismatching set
descriptions, set elements and concrete sets.
