#!/usr/bin/env bash
set -euo pipefail

# USO: ./spi_tx.sh DATA(12b) ADDR(6b)
# EX.: ./spi_tx.sh 0x0AB 0x17

# --- registradores (AXI Quad SPI) ---
SPICR=0xA0000060   # Control
SPIDTR=0xA0000068  # TX FIFO
SPISSR=0xA0000070  # Slave Select (ativo-baixo)

DATA_RAW=${1:-}
ADDR_RAW=${2:-}
[[ -n "${DATA_RAW}" && -n "${ADDR_RAW}" ]] || { echo "uso: $0 DATA(12b) ADDR(6b)"; exit 1; }

DATA=$((DATA_RAW+0))
ADDR=$((ADDR_RAW+0))
(( DATA>=0 && DATA<=0xFFF )) || { echo "DATA fora de 12 bits (0..0xFFF)"; exit 1; }
(( ADDR>=0 && ADDR<=0x3F  )) || { echo "ADDR fora de 6 bits (0..0x3F)";  exit 1; }

# cmd_word: {4'b0, 12bDATA, 2'b0, 6bADDR, 7'b0, RWb=0}
CMD=$(( ((DATA & 0xFFF) << 16) | ((ADDR & 0x3F) << 8) | 0 ))

# bit-reverse 32b (slave captura LSB-first)
bitrev32(){ local x=$1 r=0; for((i=0;i<32;i++)); do r=$(((r<<1)|((x>>i)&1))); done; echo $r; }
TX=$(bitrev32 "$CMD")

printf "WRITE  DATA=0x%03X  ADDR=0x%02X  |  CMD=0x%08X  TX(bitrev)=0x%08X\n" \
       "$DATA" "$ADDR" "$CMD" "$TX"

# sequência simples (sem espera)
sudo devmem "$SPICR" 32 0x000001E6   # INHIB|TXRST|RXRST|MANSS|MASTER|SPE
sudo devmem "$SPIDTR" 32 "$TX"       # carrega TX
sudo devmem "$SPISSR" 32 0x00000000  # CS0 baixo
sudo devmem "$SPICR"  32 0x00000086  # começa (libera INHIB)
sudo devmem "$SPISSR" 32 0x00000001  # CS0 alto
