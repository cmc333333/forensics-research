# Oracles

To provide type type of proof needed for our forensics system, we will need a
great deal of evidence. As this evidence is often very verbose (think about
the proof that a byte does *not* exist in a given array), we need a more
compact representation. We can add primitives to the types of evidence which
we may provide that will make this more concise.

To keep this kosher with our type theory, for the time being, we will
implement these primitives as oracles and delay providing their individual
proofs for later work.

These are useful to us when

* We need to evidence which can later be used in a proof
* We need to compress multiple points of evidence into a more concise statement.

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

### Subimages
Look for any thumbnails (or other additional images)within the image data. If
present, provide the associated offsets for the sub images' start end end
markers.
```haskell
[Byte] -> [(Int, Int)]
```

### String Match
JPEG formats (particularly Exif) contain optional meta data, often including
arbitrary strings. It would be useful, then to look within the designated
meta-data sections of a JPEG for the requested string. If such a match exists,
return the offsets. We can apply the same type of thinking for regular
expressions.
```haskell
String -> [Byte] -> [Int]
RegExp -> [Byte] -> [(Int, RegExpResult)]
```

### Exif Match
Exif files have pairs of key-value attributes. Check if this Exif file has the
requested key and that if so, the value matches that provided. Return the pair
of (Exif Header Offset, Key Offset) for successful results. Instead of
searching for an exact match, we could search for a regular expression.
```haskell
String -> String -> [Byte] -> [(Int, Int)]
String -> RegExp -> [Byte] -> [(Int, RegExpResult)]

##  ZIP

### Existence
Look for the file marker of a zip file (i.e. the central directory record) and
work back to determine the total size of the archive. Provide the offsets if
archive(s) are present.
```haskell
[Byte] -> [(Int, Int)]
```

### Contains File
Scan through file headers to see if any match the queries string. If so,
return the file header's offset. Similar logic can be applied to Regular
Expression searches.
```haskell
String -> [Byte] -> [Int]
RegExp -> [Byte] -> [(Int, RegExpResult)]
```

### Contains Encrypted File
Scan through the file headers to see if any were encrypted. If so, return the
file header's offset.
```haskell
[Byte] -> [Int]
```

### Contains Large or Small Files
Scan through the file headers to check if the archive contains files larger
than a given size (or smaller). Return offsets of file header and associated
file size as proof.
```haskell
Int -> [Byte] -> [(Int, Int)]
```

### Files Modified After/Before
Scan through the file headers to check if the archive contains files which
were last modified before/after some time. Returns offsets of the file header
and the associated file modification offset as proof.
```haskell
Date -> [Byte] -> [(Int, Int)]
```

### CRC Match
Scan through the file headers to check if the archive contains files which
share a CRC32 with the request. This gives us some indication that the
requested file is within the archive. Return the offset of the file header and
the associated CRC offset.
```haskell
CRC -> [Byte] -> [(Int, Int)]
```
