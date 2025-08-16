#!/usr/bin/env bash
set -euo pipefail

# USO: ./spi_rx.sh ADDR(6b)

# --- registradores (AXI Quad SPI) ---
SPICR=0xA0000060   # Control
SPIDTR=0xA0000068  # TX FIFO
SPIDRR=0xA000006C  # RX FIFO
SPISSR=0xA0000070  # Slave Select (ativo-baixo)

ADDR_RAW=${1:-}
[[ -n "$ADDR_RAW" ]] || { echo "uso: $0 ADDR(6b)"; exit 1; }
ADDR=$((ADDR_RAW+0))
(( ADDR>=0 && ADDR<=0x3F )) || { echo "ADDR fora de 6 bits (0..0x3F)"; exit 1; }

# HEADER de leitura: {4'b0, 12'b0, 2'b0, 6bADDR, 7'b0, RWb=1}
CMD=$(( ((0 & 0xFFF) << 16) | ((ADDR & 0x3F) << 8) | 1 ))

# bit-reverse 32b (slave LSB-first)
bitrev32(){ local x=$1 r=0; for((i=0;i<32;i++)); do r=$(((r<<1)|((x>>i)&1))); done; echo $r; }
TX=$(bitrev32 "$CMD")

# função que replica sua chamada "que funciona": frame + 1 leitura do RX
do_frame_read() {
  sudo devmem "$SPICR" 32 0x000001E6   # INHIB|TXRST|RXRST|MANSS|MASTER|SPE
  sudo devmem "$SPIDTR" 32 "$TX"       # carrega TX
  sudo devmem "$SPISSR" 32 0x00000000  # CS0 baixo
  sudo devmem "$SPICR"  32 0x00000086  # start (libera INHIB)
  sudo devmem "$SPISSR" 32 0x00000001  # CS0 alto
  sudo devmem "$SPIDRR" 32             # lê 1 word do RX
}

# 1) transação de "armar" (descarta leitura)
_=$(do_frame_read)

# 2) transação de "ler" (usa leitura)
RX_RAW=$(do_frame_read)
RX_NUM=$((RX_RAW+0))

# trata (corrige slip de 1 bit + bitrev) e extrai DATA(12b)
SHIFT_FIX=${SHIFT_FIX:-1}
RX_ALIGN=$(( (RX_NUM << SHIFT_FIX) & 0xFFFFFFFF ))
DEC32=$(bitrev32 "$RX_ALIGN")
DATA_RD=$(( DEC32 & 0xFFF ))

# resultado final (decimal) via echo
echo "$DATA_RD"
