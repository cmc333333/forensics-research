# Oracles

To provide type type of proof needed for our forensics system, we will need a
great deal of evidence. As this evidence is often very verbose (think about
the proof that a byte does *not* exist in a given array), we need a more
compact representation. We can add primitives to the types of evidence which
we may provide that will make this more concise.

To keep this kosher with our type theory, for the time being, we will
implement these primitives as oracles and delay providing their individual
proofs for later work.

##  Generic

### Byte Exists
Given a byte and an array of bytes, determine whether the byte exists in the
array. If so, provide a list of the offsets. If not, provide an empty list.
```haskell
Byte -> [Byte] -> [Int]
```

### Sequence Exists
Given two arrays of bytes, determine whether the first exists (contiguously)
within the latter. For each match, provide the match's starting index.
```haskell
[Byte] -> [Byte] -> [Int]
```

### Regular Expression
Given a regular expression and an array of bytes, determine if the array of
bytes matches the provided expression and return associated capture groups.
```haskell
RegExp -> [Byte] -> Maybe RegExResult
```

##  JPEG

##  ZIP
