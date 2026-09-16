# ./X900XXU9DYE5

## Samsung Galaxy Tab S8 Ultra (SM-X900 / gts8uwifi)

* Target Context
```text
Device: Samsung Galaxy Tab S8 Ultra (SM-X900)
Codename: gts8uwifi
Android: 15/ SDK 35
Build number: AP3A.240905.015.A2.X900XXU9DYE5
Build display ID: AP3A.240905.015.A2.X900XXU9DYE5
Build fingerprint: samsung/gts8uwifieea/gts8uwifi:15/AP3A.240905.015.A2/X900XXU9DYE5:user/release-keys
SoC Platform: Qualcomm Snapdragon 8 Gen 1 (SM8450 / Taro)
Kernel Version: 5.10.226-android12-9-30958166-abX900XXU9DYE5
Architecture: aarch64
```
---

## Lineage & Kernel Architecture

This codebase originally evolved from research on the **S25 Ultra** (kernel v6.x / `pa3q`) and was subsequently ported to the **S22 Ultra** (`b0q`, kernel v5.10) by **[sarabpal-dev](https://github.com/sarabpal-dev/IonStack-S22U/blob/main/MEMORY.md)**.   
The **Tab S8 Ultra (`gts8uwifi`)** target builds on the v5.10 porting work originally developed for `b0q`. 
Since both the Snapdragon variant of the S22 Ultra (`b0q`, e.g., SM-S908U/W) and the Tab S8 Ultra (`gts8` family) are based on the same SM8450/Taro platform and use an Android GKI-based v5.10 kernel, they share the same v5.10/GKI kernel architecture and execution model when compared with the v6.x architecture. While the specific numerical offsets inside `target.h` are target- and firmware-specific, they were extracted using the standard generation method (see [`target_generator/README.md`](https://github.com/sarabpal-dev/IonStack-S22U/blob/main/target_generator/README.md)) without modifying the underlying exploit logic or strings.

## Verification and Testing

The target was tested and verified in [QEMU](https://github.com/sarabpal-dev/qemu) (see also [MEMORY.md](https://github.com/sarabpal-dev/IonStack-S22U/blob/main/MEMORY.md)) as well as on a physical device ([#34](https://github.com/sarabpal-dev/IonStack-S22U/discussions/34)).

### On-Device Test Results:

* **Workqueue Alignment:** `pool_workqueue.nr_in_flight` bounds (15 vs 16) and `worker_pool` layouts (896 bytes) match the v5.10 specification.
* **VFS & FOPS Shifts:** File operations (`file_operations`) and `compat_sys_futex` layouts follow the v5.10 structure (`unlocked_ioctl` at `0x50`, `compat_ioctl` at `0x58`).
* **KASLR Leak & Page Reclaim:** KASLR slide is successfully dynamically resolved via `tracefs`. SLUB layout and `pipe_buffer` page reclamation work with high precision, recovering the `physrw` primitive (`read64 ok=1`).
* **kCFI Bypass & SELinux Patching:** Canonical `.cfi_jt` jump-table logic is bypassed. In-memory SELinux enforcement status is successfully patched (`enforcing 1 -> 0`).
* **UMH Execution & Post-Exploit Stability:** Usermodehelper (`call_usermodehelper_exec_work`) dispatch completes successfully (`retval=0`, `socket=1`), while a background **stability keeper** locks reclaimed pages to prevent post-exploitation kernel panic.

## Credits

* Huge thanks to **[sarabpal-dev](https://github.com/sarabpal-dev/IonStack-S22U)** for porting this project! The port is exceptionally high quality!
* **[DesertGhost7](https://github.com/DesertGhost7)** — Verification and testing support for **Samsung Galaxy Tab S8 Ultra** (specifically for the firmware build listed above).

### Contents

`./exp32/tls_align.S` — Thread Local Storage (TLS) stack alignment handler for `armeabi-v7a` static PIE stage compilation under NDK/Clang.    
`target.h` — Contains kernel symbol offsets, structure layouts, KASLR slide definitions, and inline documentation detailing the v5.10 vs v6.x   
`README.md`

---

> [!WARNING]
> The offsets and symbol addresses in this target profile are generated specifically for the firmware build listed above. While the core exploit logic applies to other SM8450 (Kernel 5.10) Samsung devices, running this profile on different firmware builds may cause system instability or kernel panic.
> 
> Use only on devices you own or are explicitly authorized to test.
