Require Import Coq.Arith.EqNat.
Require Import Coq.Lists.List.

Definition is_jpeg_start_tag (img: list nat) (offset_start: nat): bool :=
  andb (beq_nat (nth offset_start img 0) 255) (beq_nat (nth (offset_start + 1) img 0) 216).
Definition is_jpeg_end_tag (img: list nat) (offset_start: nat): bool :=
  andb (beq_nat (nth offset_start img 0) 255) (beq_nat (nth (offset_start + 1) img 0) 217).

Fixpoint ble_nat n m: bool :=
  match n, m with
  | O, O => false
  | O, S _ => true
  | S _, O => false
  | S n', S m' => ble_nat n' m'
end.

Definition jpeg_start_end_tags_oracle (img: list nat) (offset_start offset_end: nat): Set :=
  {(andb 
    (andb (is_jpeg_start_tag img offset_start) (is_jpeg_end_tag img offset_end)) 
    (ble_nat offset_start offset_end)) = true} +
  {False}.