# Parameterized Asynchronous FIFO (CDC Compliant)

A synthesizable, parameterized **Asynchronous FIFO** implemented in Verilog HDL for reliable data transfer across independent clock domains (`wclk` and `rclk`). Designed following standard ASIC Clock Domain Crossing (CDC) and Reset Domain Crossing (RDC) guidelines.

---

## Key Architectural Features

* **Gray-Code Pointer Synchronization:** Binary read/write pointers are converted to Gray code prior to domain crossing so only a single bit transitions per clock edge, preventing multi-bit sampling skew.
* **2-Flip-Flop CDC Synchronizers:** Synchronizes `wptr_gray` into `rclk` and `rptr_gray` into `wclk` to mitigate metastability.
* **Glitch-Free Flag Generation:**
  * **Full Flag (`wfull`):** Registered lookahead logic comparing `wgray_next` against the synchronized read pointer (`rq2_wptr`) with inverted top two MSBs.
  * **Empty Flag (`rempty`):** Registered lookahead logic comparing `rgray_next` against the synchronized write pointer (`wq2_rptr`).
* **Per-Domain Asynchronous Reset Synchronizers:** Independent active-low reset synchronizers (`wrst_n` and `rrst_n`) ensure asynchronous assertion and synchronous de-assertion within each respective clock domain.
* **Dual-Port Memory Array:** Parameterized `DATASIZE` (width) and `ADDRSIZE` (depth = $2^{\text{ADDRSIZE}}$) register-file / SRAM behavioral model.

---

## Module Hierarchy

```text
async_fifo_top
 ├── sync_r2w        # 2-FF synchronizer (Read pointer -> Write domain)
 ├── sync_w2r        # 2-FF synchronizer (Write pointer -> Read domain)
 ├── wptr_full       # Write pointer binary/Gray counters & registered wfull logic
 ├── rptr_empty      # Read pointer binary/Gray counters & registered rempty logic
 └── fifo_mem         # Dual-port parameterizable memory array
