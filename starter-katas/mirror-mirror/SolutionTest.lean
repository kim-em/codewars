import ChallengeDeps

theorem mirror_mirror {α : Type} (t : Tree α) : mirror (mirror t) = t :=
  Submission.mirror_mirror t
