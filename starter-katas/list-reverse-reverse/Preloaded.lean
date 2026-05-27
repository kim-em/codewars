-- A direct (non-tail-recursive) list reverse. The kata asks you to prove
-- that reversing twice gets you back to where you started.
def myReverse {α : Type} : List α → List α
  | []      => []
  | a :: l  => myReverse l ++ [a]
