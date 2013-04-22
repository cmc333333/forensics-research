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

Notation " [ ] " := nil : list_scope.
Notation " [ x ] " := (cons x nil) : list_scope.
Notation " [ x ; .. ; y ] " := (cons x .. (cons y nil) ..) : list_scope.

Definition disk: list nat := [ 1; 255; 216; 2; 1; 1; 4; 255; 217; 1; 1; 1; 255; 216; 1 ].

Require Export Arith.Compare_dec.
Require Export Arith.Lt.

Lemma disk_jpeg: forall (offset_start offset_end: nat),
  (jpeg_start_end_tags disk offset_start offset_end) = true <-> (offset_start = 1 /\ offset_end = 7).
Proof.
  split.

  Focus 2.
  intros.
  destruct H.
  subst.
  unfold jpeg_start_end_tags.
  simpl.
  tauto.

  intros.
  destruct (lt_dec offset_end 7).
    (* offset_end < 7 *)
    unfold jpeg_start_end_tags in H.
    symmetry in H.
    apply andb_true_eq in H.
    destruct H.
    apply andb_true_eq in H.
    destruct H.
    unfold is_jpeg_end_tag in H1.
    apply andb_true_eq in H1.
    destruct H1.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    repeat( apply lt_S_n in l).
    contradict l. apply lt_n_0.

    destruct (lt_dec 7 offset_end).
    (* 7 < offset_end *)
    unfold jpeg_start_end_tags in H.
    symmetry in H.
    apply andb_true_eq in H.
    destruct H.
    apply andb_true_eq in H.
    destruct H.
    unfold is_jpeg_end_tag in H1.
    apply andb_true_eq in H1.
    destruct H1.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. contradict l. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    destruct offset_end. simpl in H2. contradict H2. intuition.
    unfold nth in H1. simpl in H1. contradict H1. intuition.

    (* offset_end = 7 *)
    assert (offset_end = 7).
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. contradict n. intuition.
    destruct offset_end. reflexivity.
    contradict n0.
    repeat ( apply lt_n_S ).
    intuition.
    subst.
    clear n n0.
    split. Focus 2. reflexivity.

    destruct offset_start.
      (* offset_start = 0 *)
      unfold jpeg_start_end_tags in H.
      simpl in H.
      contradict H.
      eauto.
      (* offset_start > 0 *)
      destruct offset_start.
      Focus 2. (* Ignore offset_start = 1 for now *)
      (* offset_start = S S _ *)
      destruct (lt_dec offset_start 5).
        (* 1 < offset_start < 7 *)
        unfold jpeg_start_end_tags in H.
        destruct offset_start. simpl in H. contradict H. eauto.
        destruct offset_start. simpl in H. contradict H. eauto.
        destruct offset_start. simpl in H. contradict H. eauto.
        destruct offset_start. simpl in H. contradict H. eauto.
        destruct offset_start. simpl in H. contradict H. eauto.
        repeat( apply lt_S_n in l). contradict l. apply lt_n_0.

        (* 7 <= offset_start *)
        unfold jpeg_start_end_tags in H.
        symmetry in H.
        apply andb_true_eq in H.
        destruct H.
        simpl in H0.
        destruct offset_start. contradict n. apply lt_0_Sn.
        destruct offset_start. contradict n. eauto.
        destruct offset_start. contradict n. eauto.
        destruct offset_start. contradict n. eauto.
        destruct offset_start. contradict n. eauto.
        unfold ble_nat in H0.
        contradict H0. destruct offset_start. intuition. intuition.
        reflexivity.
  Show Proof.
Qed.

Check disk_jpeg.