onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group SPI /tb/uu_spi_sl/cs_n
add wave -noupdate -expand -group SPI /tb/uu_spi_sl/sclk
add wave -noupdate -expand -group SPI /tb/mosi
add wave -noupdate -expand -group SPI /tb/miso
add wave -noupdate -expand -group SPI -radix hexadecimal /tb/uu_spi_sl/cmd_word
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/rstn
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/sys_clk
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/frame_done_sclk
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/sync1
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/valid_sync
add wave -noupdate -expand -group Internals -radix hexadecimal /tb/uu_spi_sl/cmd_word_sync
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/REGS
add wave -noupdate -expand -group Internals /tb/uu_spi_sl/rwb
add wave -noupdate -expand -group Internals -radix hexadecimal /tb/uu_spi_sl/data_in
add wave -noupdate -expand -group Internals -radix unsigned /tb/uu_spi_sl/addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1762787 ps} 0}
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
WaveRestoreZoom {0 ps} {1911420 ps}
