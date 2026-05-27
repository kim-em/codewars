-- A binary tree with values at internal nodes.
inductive Tree (α : Type) : Type
  | leaf : Tree α
  | node : α → Tree α → Tree α → Tree α

-- Mirror a tree by swapping the children of every node.
def mirror {α : Type} : Tree α → Tree α
  | .leaf       => .leaf
  | .node x l r => .node x (mirror r) (mirror l)
