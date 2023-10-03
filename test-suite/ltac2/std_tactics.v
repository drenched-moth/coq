Require Import Coq.Setoids.Setoid.
Require Import Ltac2.Ltac2.

Axiom f: nat -> nat.
Definition g := f.

Axiom Foo1: nat -> Prop.
Axiom Foo2: nat -> Prop.
Axiom Impl: forall n: nat, Foo1 (f n) -> Foo2 (f n).

Create HintDb foo discriminated.
#[export] Hint Constants Opaque : foo.
#[export] Hint Resolve Impl : foo.

Goal forall x, Foo1 (f x) -> Foo2 (g x).
Proof.
  auto with foo.
  #[export] Hint Transparent g : foo.
  auto with foo.
Qed.

Goal forall (x: nat), exists y, f x = g y.
Proof.
  intros.
  eexists.
  unify f g.
  lazy_match! goal with
  | [ |- ?a ?b = ?rhs ] => unify ($a $b) $rhs
  end.
Abort.

Goal forall (x: nat), exists y, f x = g y.
Proof.
  intros.
  eexists.
  Unification.unify TransparentState.full 'f 'g.
  lazy_match! goal with
  | [ |- ?a ?b = ?rhs ] => Unification.unify_with_full_ts '($a $b) rhs
  end.
Abort.

Goal True.
Proof.
  Fail Unification.unify TransparentState.empty '(1 + 1) '2.
  Unification.unify TransparentState.full '(1 + 1) '2.
  Unification.unify (TransparentState.current ()) '(1 + 1) '2.
  Opaque Nat.add.
  Fail Unification.unify (TransparentState.current ()) '(1 + 1) '2.
  Succeed Unification.unify TransparentState.full '(1 + 1) '2.
  exact I.
Qed.


(* Test that by clause of assert doesn't eat all semicolons:
   https://github.com/coq/coq/issues/17491 *)
Goal forall (a: nat), a = a.
Proof.
  intros.
  assert (a = a) by Std.reflexivity ();
  assumption.
Qed.

(* Test that notations in by clause still work: *)
Goal forall (a: nat), a = a.
Proof.
  intros.
  assert (a = a) by exact eq_refl;
  assumption.
Qed.

Goal forall x, (forall (y : unit), y = x) -> forall (x: unit), x = x.
Proof.
  intros x H y.
  rewrite -> H at 1 2.
  reflexivity.
Qed.

Goal forall x, (forall (y : unit), x = y) -> forall (x: unit), x = x.
Proof.
  intros x H y.
  rewrite <- H at 1 2.
  reflexivity.
Qed.

Goal forall x, (forall y : unit, y = x) -> forall y : unit, y = y.
Proof.
  intros x H y.
  setoid_rewrite H at 1 2.
  setoid_rewrite <- (H y) at 1 2.
  setoid_rewrite H.
  reflexivity.
Qed.

Axiom x : unit.
Axiom H : forall {y : unit}, y = x.
Goal forall y : unit, y = y.
Proof.
  assert (H2 : tt = x).
  { setoid_rewrite (H (y := tt)).
    reflexivity. }
  setoid_rewrite (H (y := tt)) at 1 in H2.
  intros y.
  setoid_rewrite (H (y := y)) at 1.
  setoid_rewrite (H (y := y)) at 1.
  reflexivity.
Qed.
