.main clear
transcript file ""
transcript file transcript

vlog -sv -f filelist.f
vsim -voptargs="+acc" +UVM_VERBOSITY=UVM_MEDIUM work.tb_sif

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sif/rst
add wave -noupdate /tb_sif/clk
add wave -noupdate /tb_sif/x_if/wr_s
add wave -noupdate /tb_sif/x_if/rd_s
add wave -noupdate /tb_sif/x_if/addr
add wave -noupdate /tb_sif/x_if/data_wr
add wave -noupdate /tb_sif/x_if/data_rd
add wave -noupdate /tb_sif/w_if/wr_s
add wave -noupdate /tb_sif/w_if/addr
add wave -noupdate /tb_sif/w_if/data_wr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {121 ps}

run -all