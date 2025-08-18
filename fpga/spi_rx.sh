#!/usr/bin/env bash
set -euo pipefail

# how to use? ./spi_rx.sh ADDR(6b)

# --- registers (AXI Quad SPI) ---
SPICR=0xA0000060   # Control
SPIDTR=0xA0000068  # TX FIFO
SPIDRR=0xA000006C  # RX FIFO
SPISSR=0xA0000070  # Slave Select (active-low)

ADDR_RAW=${1:-}
[[ -n "$ADDR_RAW" ]] || { echo "usage: $0 ADDR(6b)"; exit 1; }
ADDR=$((ADDR_RAW+0))
(( ADDR>=0 && ADDR<=0x3F )) || { echo "ADDR out of 6 bits (0..0x3F)"; exit 1; }

# Read HEADER: {4'b0, 12'b0, 2'b0, 6bADDR, 7'b0, RWb=1}
CMD=$(( ((0 & 0xFFF) << 16) | ((ADDR & 0x3F) << 8) | 1 ))

# bit-reverse 32b (slave LSB-first)
bitrev32(){ local x=$1 r=0; for((i=0;i<32;i++)); do r=$(((r<<1)|((x>>i)&1))); done; echo $r; }
TX=$(bitrev32 "$CMD")

# function that replicates your "working" call: frame + 1 read from RX
do_frame_read() {
  sudo devmem "$SPICR" 32 0x000001E6   # INHIB|TXRST|RXRST|MANSS|MASTER|SPE
  sudo devmem "$SPIDTR" 32 "$TX"       # load TX
  sudo devmem "$SPISSR" 32 0x00000000  # CS0 low
  sudo devmem "$SPICR"  32 0x00000086  # start (release INHIB)
  sudo devmem "$SPISSR" 32 0x00000001  # CS0 high
  sudo devmem "$SPIDRR" 32             # read 1 word from RX
}

# 1) "arming" transaction (discard read)
_=$(do_frame_read)

# 2) "read" transaction (use read)
RX_RAW=$(do_frame_read)
RX_NUM=$((RX_RAW+0))

# process (fix 1-bit slip + bitrev) and extract DATA(12b)
SHIFT_FIX=${SHIFT_FIX:-1}
RX_ALIGN=$(( (RX_NUM << SHIFT_FIX) & 0xFFFFFFFF ))
DEC32=$(bitrev32 "$RX_ALIGN")
DATA_RD=$(( DEC32 & 0xFFF ))

# final result (decimal) via echo
echo "$DATA_RD"
