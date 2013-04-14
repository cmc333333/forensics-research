Require Import Coq.Arith.EqNat.
Require Import Coq.Lists.List.
Require Import Coq.Bool.BoolEq.

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

Definition jpeg_start_end_tags (img: list nat) (offset_start offset_end: nat): Set :=
  {(andb 
    (andb (is_jpeg_start_tag img offset_start) (is_jpeg_end_tag img offset_end)) 
    (ble_nat offset_start offset_end)) = true} +
  {False}.

Definition jpeg_start_end_pair (disk: list nat) (start_end: nat*nat): bool :=
  andb 
    (andb (is_jpeg_start_tag disk (fst start_end)) (is_jpeg_end_tag disk (snd start_end))) 
    (ble_nat (fst start_end) (snd start_end)). 

Definition jpeg_start_end_pairs (disk: list nat) (offsets: list (nat*nat)): bool :=
  forallb (jpeg_start_end_pair disk) offsets.

Definition all_jpegs (disk: list nat) (offsets: list (nat*nat)): Set :=
  {
    forall (offset: nat) (limit: offset < length disk),
      (andb 
        (orb 
          (negb (is_jpeg_start_tag disk offset))
          (existsb (map fst offsets) beq_nat offset)
          (* not followed by an end *)
        )
        (orb 
          (negb (is_jpeg_end_tag disk offset))
          (existsb (map snd offsets) beq_nat offset)
          (* not preceeded by a start *)
        )
      ) 

  } + { False }.