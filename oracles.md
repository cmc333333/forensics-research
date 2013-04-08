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

### Existence
Look for the start and end of image markers within the provided byte array. If
present, provide a list of these pairs.
```haskell
[Byte] -> [(Int, Int)]
```

### Exif Image
Some JPEG files (particularly those produced by digital cameras) have
additional Exif tags. As it is often useful to know if a given image comes
from a camera or digital editing software (see JFIF, below), we provide an
oracle which takes a byte array and returns whether or not it is an Exif file.
```haskell
[Byte] -> Boolean
```

### JFIF Image
Other JPEG images (particularly those edited by desktop software) have byte
sequences which indicate that they are JFIF files. This oracle verifies those
sequences and returns whether or not the provided file is a JFIF file.
```haskell
[Byte] -> Boolean
```

### Image Size
It may be useful to assert that an image is large enough to accommodate a
sub-image of particular dimensions. This oracle provides evidence (in the form
of the height and width of the main image) if this is possible, or nothing if
not.
```haskell
[Byte] -> Maybe (Int, Int)
```

### String Match
JPEG formats (particularly Exif) contain optional meta data, often including
arbitrary strings. It would be useful, then to look within the designated
meta-data sections of a JPEG for the requested string. If such a match exists,
return the offsets. We can apply the same type of thinking for regular
expressions.
```haskell
String -> [Byte] -> [Int]
RegExp -> [Byte] -> Maybe RegExResult
```

##  ZIP
