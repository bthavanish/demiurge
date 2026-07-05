# DWARF Debug Info Reference

Expertise for analyzing DWARF debug files and understanding the DWARF debug format/standard (v3-v5).

## DWARF Versions

- **DWARF v3**: Older standard, limited features
- **DWARF v4**: Improved type representation, better optimization support
- **DWARF v5**: Current standard, enhanced indexing, debug fission support

Expertise limited to versions 3, 4, and 5.

## Authoritative Sources

1. **Official DWARF Standards (dwarfstd.org)**: Use web search for specific sections
2. **LLVM DWARF Implementation**: `llvm/lib/DebugInfo/DWARF/` as reference implementation
3. **libdwarf**: Reference C implementation at github.com/davea42/libdwarf-code

## Verification Workflows

### Structural Validation

```bash
# Verify DWARF structure (compile units, DIE relationships, address ranges)
llvm-dwarfdump --verify <binary>

# Detailed error output with summary
llvm-dwarfdump --verify --error-display=full <binary>

# Machine-readable JSON error summary
llvm-dwarfdump --verify --verify-json=errors.json <binary>
```

### Quality Metrics

```bash
# Output debug info quality metrics as JSON
llvm-dwarfdump --statistics <binary>
```

### Common Verification Patterns

- **After compilation**: Verify binaries have valid DWARF before distribution
- **Comparing builds**: Use `--statistics` to detect debug info quality regressions
- **Debugging debuggers**: Identify malformed DWARF causing debugger issues
- **DWARF tool development**: Validate parser output against known-good binaries

## Search Patterns

### Simple Search

For simple cases such as name matches or exact address matches:

```bash
# Find DIE node by name (accelerator table lookup)
dwarfdump --find=<pattern> <file>

# Exhaustive name search
dwarfdump --name <pattern> [--ignore-case] [--regex] <file>

# Find DIE at specific address
dwarfdump --lookup=<address> <file>
```

### Complex Search

For more complex cases requiring custom searching:

| Step | Description | Example |
|------|-------------|---------|
| Initial Filtering | Dump entire DWARF and use grep for complex filtering | `dwarfdump <file> \| grep "float \*"` |
| Get DIE Address | Get address of matching DIE nodes | `dwarfdump <file> \| grep -B 5 "float \*"` |
| Refine Filtering | Narrow to specific DIE types | `dwarfdump <file> \| grep -B 5 "float \*" \| grep "DW_TAG_formal_parameter"` |
| Print Complete Info | Use `--lookup` with `--show-children`/`--show-parents` | `dwarfdump --lookup=<address> --show-children <file>` |

### Scripted Search

When filtering tools become too complex, write Python scripts using `pyelftools`:

```python
from elftools.elf.elffile import ELFFile

with open('binary', 'rb') as f:
    elf = ELFFile(f)
    dwarf = elf.get_dwarf_info()
    
    for CU in dwarf.iter_CUs():
        for DIE in CU.iter_DIEs():
            if DIE.tag == 'DW_TAG_subprogram':
                name = DIE.attributes.get('DW_AT_name')
                if name and b'my_function' in name.value:
                    print(f"Found: {DIE}")
```

## Coding Guidelines

### Writing Code

- **Prefer Python for Scripting**: Use Python for simpler DWARF code unless another language is specified
- **Leverage Existing Libraries**: Use existing libraries to parse/handle DWARF data
- **Refer to Library Documentation**: Consult library documentation as needed

### Modifying Code

- **Follow Existing Styles**: Adhere to existing code styles, formatting, naming conventions
- **Group Changes**: Perform logically related changes together
- **Describe Changes**: Clearly describe the purpose of each group of changes
- **Advise on Complex Changes**: Suggest especially large or complex changes before making them

### Reviewing Code

- **Only Suggest Changes**: Suggest changes or advise on refactors but do NOT modify the code
- **Consider Edge Cases**: Consider unhandled edge cases like special DIE node types, abstract base DIE nodes, specification DIE nodes, optional attributes

## Common DWARF Libraries

| Library | Language | URL | Notes |
|---------|----------|-----|-------|
| `libdwarf` | C/C++ | https://github.com/davea42/libdwarf-code | Simpler, lower-level interface. Used to implement `dwarfdump` |
| `pyelftools` | Python | https://github.com/eliben/pyelftools | Also supports parsing of ELF files in general |
| `gimli` | Rust | https://github.com/gimli-rs/gimli | Designed for performant access to DWARF data |
| `debug/dwarf` | Go | https://github.com/golang/go/tree/master/src/debug/dwarf | Standard library built-in |
| `LibObjectFile` | .NET | https://github.com/xoofx/LibObjectFile | Also supports interfacing with object files (ELF, PE/COFF, etc) |

## dwarfdump Options

### LLVM dwarfdump

- `dwarfdump --version`: Display version information
- `dwarfdump --help`: Display available options
- `dwarfdump --all`: Dump all DWARF sections
- `dwarfdump --<debug_section>`: Dump a particular DWARF section (e.g. `--debug-addr`, `--debug-names`)
- `dwarfdump --show-children [--recurse-depth=<n>]`: Show DIE children when selectively printing entries
- `dwarfdump --show-parents [--parent-recurse-depth=<n>]`: Show DIE parents when selectively printing entries
- `dwarfdump --show-form`: Show DWARF form types after attribute types
- `dwarfdump --find=<pattern>`: Search accelerator tables for exact name match
- `dwarfdump --name <pattern> [--ignore-case] [--regex]`: Exhaustive name search
- `dwarfdump --lookup=<address>`: Find DIE node at specific address
- `dwarfdump --verify`: Verify DWARF file is well-formed
- `dwarfdump --verbose`: Print more low-level encoding details

### readelf

- `readelf --debug-dump [debug_section]`: Dump a particular DWARF section
- `readelf --dwarf-depth=N`: Do not display DIEs at depth N or greater
- `readelf --dwarf-start=N`: Display DIE nodes starting at offset N

## Choosing Your Approach

```
├─ Need to verify DWARF data integrity?
│   └─ Use `llvm-dwarfdump --verify`
├─ Need to answer questions about the DWARF standard?
│   └─ Search dwarfstd.org or reference LLVM/libdwarf source
├─ Need simple section dump or general ELF info?
│   └─ Use `readelf`
├─ Need to parse, search, and/or dump DWARF DIE nodes?
│   └─ Use `dwarfdump`
└─ Need to write, modify, or review code that interacts with DWARF data?
    └─ Refer to the coding guidelines above
```

## When NOT to Use

- **DWARF v1/v2 Analysis**: Expertise limited to versions 3, 4, and 5
- **General ELF Parsing**: Use standard ELF tools if DWARF data isn't needed
- **Executable Debugging**: Use dedicated debugging tools (gdb, lldb, etc)
- **Binary Reverse Engineering**: Use dedicated RE tools (Ghidra, IDA) unless specifically analyzing DWARF sections
- **Compiler Debugging**: DWARF generation issues are compiler-specific
