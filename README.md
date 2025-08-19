# (simple) SPI Slave

A small **SPI slave** implementation in SystemVerilog, tested on **ZCU106** using Xilinx **AXI Quad SPI** (v3.2) with the Zynq PS.  
Includes RTL, a ModelSim/Questa testbench (works on the free edition), FPGA helper scripts, and waveform screenshots.

## Architecture

<img width="1308" height="468" alt="image" src="https://github.com/user-attachments/assets/fcaddbbb-cbc9-4b6f-b2e2-f5baa21e1f30" />

---

## TL;DR
- **32-bit command frame**, **MSB-first on MOSI**.
- **Two-step read**: (1) issue READ+ADDR, (2) clock another frame to shift data out.
- **Write is single frame**: issue WRITE+ADDR+DATA.
- **Clocks**: `sys_clk = 100 MHz`, `sclk ≈ 25 MHz` (asynchronous).
- **CDC**: edge-based strobe + 2-FF sync for “frame done” into the system clock domain.

---

## Repo Layout
```

svlog/   RTL (spi_sl.sv)
bench/   Testbench + Makefile + wave.do (ModelSim/Questa)
fpga/    Helper scripts (AXI Quad SPI) + ZCU106 constraints (spi.xdc)
docs/    Screenshots of read/write waveforms

```

---

## The Protocol

**Frame size**: 32 bits (MOSI captured on `posedge sclk`, MSB-first)

```
31          28 27           16 15 14  13           8 7          1     0
+--------------+---------------+-----+---------------+------------+----+
|  reserved    |   DATA[11:0]  |  0  |  ADDR[5:0]    |  reserved  | RWb|
+--------------+---------------+-----+---------------+------------+----+
```

- `R/Wb = 0` → **WRITE**
- `R/Wb = 1` → **READ (stage 1: load)**  
  Data is made available for the **next** frame (stage 2), while you keep clocking `sclk`.

**Addressing & width**
- Register file depth: parameterized (`SPI_NUM_OF_REGS`, default **16**).  
  Valid `ADDR` range: `0 .. SPI_NUM_OF_REGS-1`.
- Register width: **12 bits** (`DATA[11:0]`).

> **Bit order note:** MOSI is **MSB-first**. MISO shifts `dout_miso[bitcnt]` starting at bit 0, i.e., **LSB-first on the wire**. Many masters expect MSB-first; if so, **reverse bits in software** or adapt the RTL indexing for MISO.

---

## Quick Examples

### Pack a command (C-style)

```C

// RW=0 (write)/1(read), addr:6b, data:12b
uint32_t spi_cmd(uint8_t rw, uint8_t addr, uint16_t data12) {
  return ( (uint32_t)(rw & 1))
        | ((uint32_t)(addr & 0x3F) << 8)
        | ((uint32_t)(data12 & 0x0FFF) << 16);
}

````

### Write (single frame)

* Send `RW=0`, `ADDR`, `DATA`.
* Effect: `REGS[ADDR] <= DATA[11:0]`. (Also mirrors to `leds[7:0]` in this demo.)

### Read (two frames)

1. **Frame A**: send `RW=1` with `ADDR` (DATA can be 0).
   The slave latches `REGS[ADDR]` into an internal output register.
2. **Frame B**: clock 32 more SCLKs; master captures MISO bits.
   Return word is `{20'b0, DATA[11:0]}` (data in **lower 12 bits**).

---

## Clocks & CDC

- `sys_clk` (100 MHz) and `sclk` (~25 MHz) are **asynchronous**.  
- A **two-FF synchronizer** brings a “frame complete” strobe (`frame_done_sclk`) into `sys_clk`.  
- On this strobe, the 32-bit command word (stable after frame end) is sampled in the system domain.  
- RTL marks the strobe with `(* ASYNC_REG = "TRUE" *)`.  

For **MISO**, no extra synchronizer is required:  
the data to be returned is latched during the previous frame and remains stable until the next transfer, so the master always reads a valid, settled value directly on `sclk`.  

Timing constraints for SPI IO and CDC are provided in `fpga/spi.xdc`. Adjust for your board as needed.

---

## Build & Sim (ModelSim/Questa)

Requirements: ModelSim/Questa (free edition is fine).

```bash
cd bench

# Typical flow (see Makefile)
make run_questa # compiles & runs; produces vsim.wlf and dump.vcd

# Optional: open GUI with preloaded waveforms
make questa_gui
```

Artifacts:

* `bench/vsim.wlf` – GUI waveform.
* `docs/` has screenshots:

  * ![Write frame](docs/Screenshot%202025-08-18%20at%2020.06.05.png)
  * ![Read frame](docs/Screenshot%202025-08-18%20at%2020.16.31.png)

---

## FPGA Demo (ZCU106 + AXI Quad SPI)

1. Add `svlog/spi_sl.sv` to your Vivado project.
2. Instantiate **AXI Quad SPI** (v3.2) and hook `sclk/cs_n/mosi/miso`.
   Connect the AXI side to PS or PL as you prefer.
3. Add constraints from `fpga/spi.xdc` (IO and timing).
4. Program the FPGA.
5. Use `fpga/spi_tx.sh` and `fpga/spi_rx.sh` as simple helpers to poke the core via the AXI Quad SPI.
   (Open the scripts and adjust device paths/params for your setup.)

> I also drop an ILA for debugging — highly recommended to enjoy the waveforms. 😊

---

## Parameters

* `SPI_TRANSF_SIZE` (default 32): frame width in bits.
* `SPI_NUM_OF_REGS` (default 16): number of 12-bit registers.

---

## Gotchas & Notes

* **MISO bit order**: currently LSB-first. If your master is MSB-first-only, either:

  * reverse bits in software, or
  * change `miso <= dout_miso[bitcnt_miso];` to index from MSB.
* **Reserved bits** in the frame must be sent as **0**.
* **Reset** clears the register bank and output latch; LEDs mirror `DATA[7:0]` on writes (demo feature).
* **Throughput**: this is a simple register access protocol, not a streaming SPI.

---

## Contributing

It’s small, but fun. If you want to improve it:

* Open an **issue** with ideas/bugs; or
* Send a **PR** directly.

No FPGA? No excuses — the testbench runs on the free ModelSim. Have fun! 😄
