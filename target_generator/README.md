# Target Generator (`target.h`)

Tools to extract kernel symbols, configs, and function offsets directly from an uncompressed kernel binary (`Image`) to auto-patch `target.h`.

> [!NOTE]
> This target generator extracts symbols and kernel offsets for **Samsung devices running the Linux Android 12 5.10 kernel** (covering Qualcomm Snapdragon and Samsung Exynos platforms).
> `generate_target.py` calculates dynamic offsets and patches placeholders while kernel struct definitions and layouts remain aligned with Samsung's 5.10 GKI implementation.

---

## 📋 Step-by-Step Instructions

### Step 1: Install Dependencies
Installs the Capstone disassembler module required by the Python script to analyze kernel instructions.
```bash
pip install capstone
```

### Step 2: Compile the `kallsyms` Extractor
Compiles `kallsyms.c` into an executable tool used to locate and parse symbol table structures inside the kernel binary.
```bash
gcc -O2 kallsyms.c -o kallsyms
```

### Step 3: Extract Symbol Table (`kallsyms.txt`)
Scans the kernel `Image` binary and generates `kallsyms.txt` containing symbol names and addresses.
```bash
./kallsyms Image
```

### Step 4: Extract Kernel Config (`config.txt`)
Extracts compressed `CONFIG_*` settings from the kernel `Image` and saves them to `config.txt`.
```bash
./extract-ikconfig Image > config.txt
```

### Step 5: Generate & Patch `target.h`
Calculates dynamic offsets using `kallsyms.txt`, `config.txt`, and disassembly from `Image`, then updates placeholder defines in `target.h`.
```bash
python3 generate_target.py kallsyms.txt config.txt Image --template target.h -o target.h
```

### Step 6: Create Target Directory & Porting Setup

When adding support for a new device build, **do not just place a bare `target.h` into an empty folder**:

1. **Find a matching sibling target**:
   Check `src/targets/` (refer to the supported devices table in the main [README.md](../README.md)) to see if an existing target matches your device model, SoC family (Snapdragon vs Exynos), or carrier variant (e.g. `S901U` vs `S901U1`, `S906E`, `S908B`, `S908W`, etc.).
2. **Copy matching target files**:
   Many targets include target-specific fixes, race timing parameters, or source overrides (such as `main.c`, `fops.c`, `su_daemon.c`, `exp32/`, or `exp64/`). Create your target folder and copy the contents of the closest sibling target into it:
   ```bash
   mkdir -p ../src/targets/<YOUR_FIRMWARE_BUILD>
   cp -r ../src/targets/<SIBLING_TARGET>/* ../src/targets/<YOUR_FIRMWARE_BUILD>/
   ```
   *(If your device matches the generic baseline implementation with no sibling overrides needed, you can start from a clean directory).*
3. **Place your generated `target.h`**:
   Copy or overwrite your newly generated `target.h` into your new target folder:
   ```bash
   cp target.h ../src/targets/<YOUR_FIRMWARE_BUILD>/target.h
   ```
4. **Compile for your target**:
   Build the exploit binaries by specifying your target name in `PROJECT`:
   ```bash
   make PROJECT=<YOUR_FIRMWARE_BUILD> clean preload root-helper
   ```

---

## ⚡ All-in-One Command

Run the complete pipeline sequentially in one line:
```bash
gcc -O2 kallsyms.c -o kallsyms && ./kallsyms Image && ./extract-ikconfig Image > config.txt && python3 generate_target.py kallsyms.txt config.txt Image --template target.h -o target.h
```

---

## 📁 Files Reference

- `generate_target.py` — Main script that resolves kernel offsets and patches the header file.
- `target.h` — C header template containing target definitions to be patched.
- `kallsyms.c` — Source code for extracting the symbol table from raw kernel binary data.
- `extract-ikconfig` — Shell script to unpack kernel configuration settings (`CONFIG_*`).

