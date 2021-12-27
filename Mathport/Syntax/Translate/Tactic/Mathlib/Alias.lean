/-
Copyright (c) 2021 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Mathport.Syntax.Translate.Tactic.Basic

open Lean

namespace Mathport.Translate.Tactic
open AST3 Parser

-- # tactic.alias

@[trUserCmd «alias»] def trAlias (doc : Option String) : TacM Syntax := do
  let (old, args) ← parse $ do (← ident, ←
    do { tk "<-"; Sum.inl $ ← ident* } <|>
    do { tk "↔" <|> tk "<->"; Sum.inr $ ←
      (tk "." *> tk "." *> pure none) <|>
      do some (← ident_, ← ident_) })
  let old ← mkIdentI old
  match args with
  | Sum.inl ns => `(command| alias $old ← $(← liftM $ ns.mapM mkIdentI)*)
  | Sum.inr none => `(command| alias $old ↔ ..)
  | Sum.inr (some (l, r)) => do
    `(command| alias $old ↔ $(← trBinderIdentI l) $(← trBinderIdentI r))

