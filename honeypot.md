# Honeypot Recovery Tools/Actions

## Types

* Block = list[byte]
* DeletedINode <: INode
* ArchiveFile <: File
* SuspiciousFileName <: FileName
* SystemFileName <: FileName
* MaliciousFingerprint <: Fingerprint
* ModificationHistory

## Functions

### deleted - Recover Deleted INodes (ils/igrabber.pl)
```Block -> ```

* ```List[DeletedINode]```
* Only ```DeletedINodes``` in the Block

### inode2File - Recover Files (icat)
```Inode -> File```

### isZip? - Is an archived file? (file)
```File -> Option[ArchiveFile]```

### zipContents - List Archive Contents (tar)
```ArchiveFile -> List[FileName]```

### unzip - Unzip an archive (tar)
```ArchiveFile -> List[File]```

### suspiciousFile? - Suspicious FileName ?
```FileName -> Option[SuspiciousFileName]```

### hash - Fingerprint (md5)
```File -> Fingerprint```

### malicious? - Malicious Fingerprint?
```Fingerprint -> Option[MaliciousFingerprint]```

### modHistory - Modification History (mactime)
```INode -> ModificationHistory```

### listFiles - List All Files (mount, find)
```Block ->```

* ```List[FileName]```
* All non-deleted files in the block

### systemFile? - Is A System File?
```FileName -> Option[SystemFileName]```

### fileName2INode - Retrieve INode with FileName
```FileName -> INode```

## Scripts

### [Matt Borland](http://old.honeynet.org/scans/scan15/som/som6.txt)

#### RootKit Retrieval
* ```Disk -> (Exhaustive) List[DeletedINode]``` (deleted)
* ```(Exhaustive) List[DeletedINode] -> List[File]``` (map(inode2File))
* ```List[File] -> List[ArchiveFile]``` (flatMap(isZip?))
* ```List[ArchiveFile] -> List[FileName]``` (flatMap(zipContents))
* ```List[FileName] -> List[SuspiciousFileName]``` (flatMap(suspiciousFile?)) 
  - in this case, ssh

#### Constructing a Timeline
* ```Disk -> (Exhaustive) List[DeletedINode]``` (deleted)
* ```(Exhaustive) List[DeletedINode] -> List[ModificationHistory]``` 
  (modHistory) - history of deleted files
* ```Disk -> (Exhaustive) List[FileName]``` (listFiles)
* ```(Exhaustive) List[FileName] -> List[SystemFileName]``` 
  (flatMap(systemFile?))
* ```List[SystemFileName] -> List[INode]``` (fileName2INode)
* ```List[INode] -> List[ModificationHistory]``` (modHistory) - history of 
  system files

### [Marlon Jabbur](http://old.honeynet.org/scans/scan15/som/som19.txt)

#### Discovery
Same as Borland's Rootkit Retrieval

#### Rootkit Files
* ```Disk -> (Exhaustive) List[DeletedINode]``` (deleted)
* ```(Exhaustive) List[DeletedINode] -> List[File]``` (map(inode2File))
* ```List[File] -> List[ArchiveFile]``` (flatMap(isZip?))
* ```List[ArchiveFile] -> List[ArchiveFile]``` (flatMap(flatMap(zipContents),
  suspiciousFile?))
* ```List[ArchiveFile] -> List[File]``` (flatMap(unzip))

#### Was it installed?
Continuing from above:
* ```List[File] -> List[FingerPrint]``` (map(hash)) - hash the malicious files
* ```Disk -> (Exhaustive) List[FileName]``` (listFiles)
* ```(Exhaustive) List[FileName] -> List[INode]``` (fileName2INode)
* ```List[INode] -> List[File]``` (map(inode2File))
* ```List[File] -> List[Fingerprint]``` (map(hash))
* ```List[Fingerprint] -> List[Fingerprint] -> List[Fingerprint]``` (union)

### [Jason Lee](http://old.honeynet.org/scans/scan15/som/som33.html)

#### Finding Suspicious Files
* ```Disk -> (Exhaustive) List[FileName]``` (listFiles)
* ```(Exhaustive) List[FileName] -> List[SuspiciousFileName]``` 
  (flatMap(suspiciousFile?)) - in this case, being in the /dev/ directory

#### Finding Suspicious History
Continuing from above,
* ```Disk -> (Exhaustive) List[FileName]``` (listFiles)
* ```(Exhaustive) List[FileName] -> List[SystemFileName]``` 
  (flatMap(systemFile?))
* ```List[SystemFileName] -> List[INode]``` (fileName2INode)
* ```List[INode] -> List[ModificationHistory]``` (modHistory) - history of 
  system files
* ```List[SuspiciousFileName] -> List[Inode]``` (fileName2INode)
* ```List[INode] -> List[ModificationHistory]``` (modHistory) - history of
  suspicious files

#### Finding Known Malicious Files
Find deleted archives (as described above)
* ```List[ArchiveFile] -> List[File]``` (flatMap(unzip))
* ```List[File] -> List[FingerPrint]``` (map(hash))
* ```List[FingerPrint] -> List[MaliciousFingerPrint]``` (flatMap(malicious?))


## Odds and Ends
### Search for String in Whole Disk (grep?)
```Disk x String -> List[Offsets]```

###  Check Owners/Groups Exist


