Require Import Coq.Arith.EqNat.
Require Import Coq.Lists.List.
Require Import Coq.Bool.BoolEq.

Definition is_jpeg_start_tag (disk: list nat) (offset_start: nat): bool :=
  andb (beq_nat (nth offset_start disk 0) 255) (beq_nat (nth (offset_start + 1) disk 0) 216).
Definition is_jpeg_end_tag (disk: list nat) (offset_start: nat): bool :=
  andb (beq_nat (nth offset_start disk 0) 255) (beq_nat (nth (offset_start + 1) disk 0) 217).

Fixpoint ble_nat n m: bool :=
  match n, m with
  | O, O => false
  | O, S _ => true
  | S _, O => false
  | S n', S m' => ble_nat n' m'
end.

Definition jpeg_start_end_tags (disk: list nat) (offset_start offset_end: nat): bool :=
  andb 
    (andb (is_jpeg_start_tag disk offset_start) (is_jpeg_end_tag disk offset_end)) 
    (ble_nat offset_start offset_end).

Definition only_jpeg (disk: list nat) (offset_start offset_end: nat): Set :=
  {and
    ((jpeg_start_end_tags disk offset_start offset_end) = true)
    (forall (offset: nat) (limit: offset < length disk),
      (andb
        (orb (* Start Tag *)
          (orb (negb (is_jpeg_start_tag disk offset)) (beq_nat offset offset_start))
          (orb
            (andb (* Offset < Start *)
              (ble_nat offset offset_start)
              (negb (existsb (is_jpeg_end_tag disk) 
                (firstn (offset_start - offset) (skipn offset disk))))
            )
            (andb (* Offset > End *)
              (ble_nat offset_end offset)
              (negb (existsb (is_jpeg_end_tag disk) (skipn offset disk)))
            )
          )
        )
        (orb (* End Tag *)
          (orb (negb (is_jpeg_end_tag disk offset)) (beq_nat offset offset_end))
          (orb
            (andb (* Offset < Start *)
              (ble_nat offset offset_start)
              (negb (existsb (is_jpeg_start_tag disk) (firstn offset disk)))
            )
            (andb (* Offset > End *)
              (ble_nat offset_end offset)
              (negb (existsb (is_jpeg_start_tag disk) (skipn offset_end disk)))
            )
          )
        )
      ) = true)
  } + { False }.

Definition subimage (disk: list nat) (offset_start offset_end subimage_end: nat): Set :=
  {and
    ((andb 
      (jpeg_start_end_tags disk offset_start offset_end)
      (jpeg_start_end_tags disk (offset_end + 2) subimage_end)
    ) = true)
    (only_jpeg (skipn (offset_end + 2) disk) 1 (subimage_end - offset_end - 2))
  } + { False }.

Definition exif_match (disk: list nat) (tag value: list nat): Set :=
  { True
  } + { False }.