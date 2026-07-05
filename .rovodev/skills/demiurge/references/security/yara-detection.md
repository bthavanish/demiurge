# YARA Rule Authoring Reference

## Core Principles

1. **Strings must generate good atoms** — 4-byte subsequences for fast matching
2. **Target specific families, not categories** — "Detects LockBit 3.0 config" not "Detects ransomware"
3. **Test against goodware before deployment** — validate on VirusTotal goodware corpus
4. **Short-circuit with cheap checks first** — `filesize < 10MB and uint16(0) == 0x5A4D` before strings
5. **Metadata is documentation** — description, author, reference, date required

## String Quality Tiers

### Gold Tier (Almost Always Unique)
- Mutex names: `"Global\\MyMalwareMutex"`
- Stack strings (decoded at runtime)
- PDB paths: `"C:\\Users\\dev\\malware.pdb"`

### Silver Tier (Usually Unique)
- C2 paths: `"/api/beacon/check"`
- Configuration markers: `"CONFIG_START"`
- Custom protocol headers: `"BEACON_1.0"`

### Bronze Tier (Unique with Context)
- Unique error messages
- Campaign IDs

### Always Reject
- API names (VirtualAlloc, CreateRemoteThread)
- Common paths (C:\Windows\, cmd.exe)
- Format strings (%s, %d)
- Common libraries (KERNEL32.dll)
- JavaScript frameworks (require, fetch, axios)

## String Types

```yara
$text = "Hello World"              // Basic ASCII
$text_wide = "Hello" wide          // UTF-16LE
$text_both = "Hello" ascii wide    // Either encoding
$text_nocase = "hello" nocase      // Case-insensitive (doubles atoms)
$hex = { 4D 5A 90 00 }             // Exact bytes
$wild = { 4D 5A ?? ?? }            // Wildcards
$jump = { 4D 5A [2-4] 50 45 }     // Variable-length jump (bounded!)
$url = /https?:\/\/[a-z0-9]{5,50}\.onion/  // Bounded regex
```

## Atom Theory

YARA extracts 4-byte atoms. Best atoms are:
- Rare in target files (unique byte sequences)
- Unambiguous (no wildcards in 4-byte window)
- Not in common data

**Slow pattern killers:** Strings <4 bytes, repeated bytes (0000, 9090), unbounded regex (`.*`), leading wildcards, common byte sequences.

## Performance Optimization

Order conditions cheapest → most expensive:
1. `filesize < 10MB` (instant)
2. `uint16(0) == 0x5A4D` (nearly instant)
3. String matches (cheap with good atoms)
4. Module checks (expensive)

**Regex rules:**
- Anchor every regex to a 4+ byte literal string atom
- Bounded ranges: `.{0,30}` not `.*`
- Always bounded jumps in hex: `{ 4D 5A [2-4] 50 45 }` not `{ 4D 5A [-] 50 45 }`

## Naming Convention

```
{CATEGORY}_{PLATFORM}_{FAMILY}_{VARIANT}_{DATE}
```

**Categories:** MAL_, HKTL_, WEBSHELL_, EXPL_, SUSP_, PUA_, GEN_
**Platforms:** Win_, Lnx_, Mac_, Android_, Multi_
**Example:** `MAL_Win_Emotet_Loader_Jan25`

## Metadata Requirements

```yara
meta:
    description = "Detects X malware via Y unique feature"
    author = "Your Name <email>"
    reference = "https://analysis-url.com"
    date = "2025-01-29"
```

## Platform-Specific Detection

### PE Files
```yara
condition:
    filesize < 10MB and
    uint16(0) == 0x5A4D and
    all of ($strings_*)
```

### JavaScript/npm
- Look for obfuscator signatures (`_0x`, `fromCharCode` chains)
- eval+decode combos: `/eval\s*\(\s*(unescape|atob)\s*\(/`
- Credential theft: `.npmrc`, `.ssh/id_rsa`, `.aws/credentials` + file read + exfil

### Chrome Extensions (crx module)
```yara
import "crx"
condition:
    crx.is_crx and
    for any perm in crx.permissions : (perm == "debugger")
```

**Red flags:** `nativeMessaging` + `downloads`, `debugger` permission, `<all_urls>`

### Android Apps (dex module)
```yara
import "dex"
condition:
    dex.is_dex and
    dex.contains_class("Ldalvik/system/DexClassLoader;")
```

**Red flags:** Single-letter class names, `DexClassLoader` reflection, encrypted assets

### macOS
```yara
condition:
    (uint32(0) == 0xFEEDFACF or uint32(0) == 0xCAFEBABE) and
    any of ($lib*) and any of ($behav*)
```

## Testing Checklist

- [ ] `yr check` passes (syntax)
- [ ] `yr fmt --check` passes (formatting)
- [ ] Matches all target samples (positive)
- [ ] Zero matches on goodware corpus (negative)
- [ ] Tested against packed variants
- [ ] Performance <1s per file average
- [ ] Peer reviewed

## FP Investigation

```
1. Which string matched? → yr scan -s rule.yar fp_file
2. Is it in a legitimate library? → Add exclusion
3. Common development pattern? → Find more specific indicator
4. Multiple generic strings? → Tighten to require all + unique marker
```
