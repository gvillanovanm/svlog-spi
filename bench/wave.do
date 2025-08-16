onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/uu_spi_sl/sclk
add wave -noupdate /tb/uu_spi_sl/cs_n
add wave -noupdate /tb/mosi
add wave -noupdate /tb/uu_spi_sl/bitcnt
add wave -noupdate -radix hexadecimal /tb/uu_spi_sl/cmd_word
add wave -noupdate /tb/uu_spi_sl/rstn
add wave -noupdate /tb/uu_spi_sl/sys_clk
add wave -noupdate /tb/uu_spi_sl/frame_done_sclk
add wave -noupdate /tb/uu_spi_sl/sync1
add wave -noupdate /tb/uu_spi_sl/valid_sync
add wave -noupdate -radix hexadecimal /tb/cmd_word
add wave -noupdate -radix hexadecimal /tb/uu_spi_sl/cmd_word_sync
add wave -noupdate /tb/uu_spi_sl/REGS
add wave -noupdate /tb/uu_spi_sl/rwb
add wave -noupdate -radix hexadecimal /tb/uu_spi_sl/data_in
add wave -noupdate -radix unsigned /tb/uu_spi_sl/addr
add wave -noupdate -divider ====
add wave -noupdate /tb/uu_spi_sl/data_out
add wave -noupdate /tb/uu_spi_sl/dout_miso
add wave -noupdate /tb/uu_spi_sl/bitcnt_miso
add wave -noupdate /tb/miso
add wave -noupdate /tb/sclk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {141572919 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 88
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {139678779 ps} {143019203 ps}
