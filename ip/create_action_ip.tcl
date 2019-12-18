
## Env Variables

set action_root [lindex $argv 0]
set fpga_part  	[lindex $argv 1]
#set fpga_part    xcvu9p-flgb2104-2l-e
#set action_root ../

set aip_dir 	$action_root/ip
set log_dir     $action_root/../../hardware/logs
set log_file    $log_dir/create_action_ip.log
set src_dir 	$aip_dir/action_ip_prj/action_ip_prj.srcs/sources_1/ip

# Create a new Vivado IP Project
puts "\[CREATE_ACTION_IPs..........\] start [clock format [clock seconds] -format {%T %a %b %d/ %Y}]"
puts "                        FPGACHIP = $fpga_part"
puts "                        ACTION_ROOT = $action_root"
puts "                        Creating IP in $src_dir"
create_project action_ip_prj $aip_dir/action_ip_prj -force -part $fpga_part -ip >> $log_file

## Project IP Settings
## General
puts "                        Generating fifo_1024 ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_1024 >> $log_file
set_property -dict [list CONFIG.Component_Name {fifo_1024} CONFIG.Input_Data_Width {1024} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {1024} CONFIG.Output_Depth {512} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {9} CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} CONFIG.Full_Threshold_Assert_Value {480} CONFIG.Full_Threshold_Negate_Value {479}] [get_ips fifo_1024]
set_property generate_synth_checkpoint false [get_files $src_dir/fifo_1024/fifo_1024.xci]
generate_target all [get_files  $src_dir/fifo_1024/fifo_1024.xci] >> $log_file

puts "                        Generating fifo_1024_out ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_1024_out >> $log_file
set_property -dict [list CONFIG.Component_Name {fifo_1024_out} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {1024} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {1024} CONFIG.Output_Depth {512} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {9} CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant} CONFIG.Full_Threshold_Assert_Value {480} CONFIG.Full_Threshold_Negate_Value {479} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips fifo_1024_out]
set_property generate_synth_checkpoint false [get_files $src_dir/fifo_1024_out/fifo_1024_out.xci]
generate_target all [get_files  $src_dir/fifo_1024_out/fifo_1024_out.xci] >> $log_file

puts "                        Generating top_ram ......"
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name top_ram >> $log_file
set_property -dict [list CONFIG.Component_Name {top_ram} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A {128} CONFIG.Write_Depth_A {1024} CONFIG.Read_Width_A {128} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Write_Width_B {128} CONFIG.Read_Width_B {128} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips top_ram]
set_property generate_synth_checkpoint false [get_files $src_dir/top_ram/top_ram.xci]
generate_target all [get_files  $src_dir/top_ram/top_ram.xci] >> $log_file

puts "                        Generating top_derr_ram ......"
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name top_derr_ram >> $log_file
set_property -dict [list CONFIG.Component_Name {top_derr_ram} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {1024} CONFIG.Read_Width_A {32} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips top_derr_ram]
set_property generate_synth_checkpoint false [get_files $src_dir/top_derr_ram/top_derr_ram.xci]
generate_target all [get_files  $src_dir/top_derr_ram/top_derr_ram.xci] >> $log_file

puts "                        Generating rom_pow ......"
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name rom_pow >> $log_file
set_property -dict [list CONFIG.Component_Name {rom_pow} CONFIG.Memory_Type {Single_Port_ROM} CONFIG.Write_Width_A {16} CONFIG.Write_Depth_A {512} CONFIG.Read_Width_A {16} CONFIG.Write_Width_B {16} CONFIG.Read_Width_B {16} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Load_Init_File {true} CONFIG.Coe_File {~/oc-accel/actions/hdl_computing/ip/rom_pow.coe} CONFIG.Port_A_Write_Rate {0}] [get_ips rom_pow]
set_property generate_synth_checkpoint false [get_files $src_dir/rom_pow/rom_pow.xci]
generate_target all [get_files  $src_dir/rom_pow/rom_pow.xci] >> $log_file

close_project
puts "\[CREATE_ACTION_IPs..........\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
