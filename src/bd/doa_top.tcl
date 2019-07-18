
################################################################
# This is a generated script based on design: doa_top
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source doa_top_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART tul.com.tw:pynq-z2:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name doa_top

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:user:axis_acc_convert:1.0\
xilinx.com:user:axis_bram_4_channel:1.0\
xilinx.com:user:axis_compare:1.0\
xilinx.com:user:axis_fft_config:1.0\
xilinx.com:user:axis_inverse_number:1.0\
xilinx.com:user:axis_msr_keep:1.0\
xilinx.com:ip:cmpy:6.0\
xilinx.com:ip:div_gen:5.1\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:xfft:9.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:user:respeaker_stream_v1_0:1.0\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR_0 ]
  set FIXED_IO_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO_0 ]
  set IIC_0_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC_0_0 ]

  # Create ports
  set I2S_i_0 [ create_bd_port -dir I -from 2 -to 0 I2S_i_0 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]

  # Create instance: axis_acc_convert_0, and set properties
  set axis_acc_convert_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_acc_convert:1.0 axis_acc_convert_0 ]

  # Create instance: axis_acc_convert_1, and set properties
  set axis_acc_convert_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_acc_convert:1.0 axis_acc_convert_1 ]

  # Create instance: axis_bram_4_channel_0, and set properties
  set axis_bram_4_channel_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_bram_4_channel:1.0 axis_bram_4_channel_0 ]

  # Create instance: axis_compare_0, and set properties
  set axis_compare_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_compare:1.0 axis_compare_0 ]

  # Create instance: axis_fft_config_0, and set properties
  set axis_fft_config_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_fft_config:1.0 axis_fft_config_0 ]

  # Create instance: axis_inverse_number_0, and set properties
  set axis_inverse_number_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_inverse_number:1.0 axis_inverse_number_0 ]

  # Create instance: axis_inverse_number_1, and set properties
  set axis_inverse_number_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_inverse_number:1.0 axis_inverse_number_1 ]

  # Create instance: axis_inverse_number_2, and set properties
  set axis_inverse_number_2 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_inverse_number:1.0 axis_inverse_number_2 ]

  # Create instance: axis_inverse_number_3, and set properties
  set axis_inverse_number_3 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_inverse_number:1.0 axis_inverse_number_3 ]

  # Create instance: axis_msr_keep_0, and set properties
  set axis_msr_keep_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_msr_keep:1.0 axis_msr_keep_0 ]

  # Create instance: axis_msr_keep_1, and set properties
  set axis_msr_keep_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:axis_msr_keep:1.0 axis_msr_keep_1 ]

  # Create instance: cmpy_0, and set properties
  set cmpy_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 cmpy_0 ]
  set_property -dict [ list \
   CONFIG.APortWidth {32} \
   CONFIG.BPortWidth {32} \
   CONFIG.FlowControl {Blocking} \
   CONFIG.MinimumLatency {16} \
   CONFIG.OutputWidth {64} \
 ] $cmpy_0

  # Create instance: cmpy_1, and set properties
  set cmpy_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 cmpy_1 ]
  set_property -dict [ list \
   CONFIG.APortWidth {32} \
   CONFIG.BPortWidth {32} \
   CONFIG.FlowControl {Blocking} \
   CONFIG.MinimumLatency {16} \
   CONFIG.OutputWidth {64} \
 ] $cmpy_1

  # Create instance: div_gen_0, and set properties
  set div_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:div_gen:5.1 div_gen_0 ]
  set_property -dict [ list \
   CONFIG.FlowControl {Blocking} \
   CONFIG.OutTready {true} \
   CONFIG.clocks_per_division {1} \
   CONFIG.dividend_and_quotient_width {64} \
   CONFIG.divisor_width {64} \
   CONFIG.fractional_width {64} \
   CONFIG.latency {135} \
   CONFIG.remainder_type {Fractional} \
 ] $div_gen_0

  # Create instance: div_gen_1, and set properties
  set div_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:div_gen:5.1 div_gen_1 ]
  set_property -dict [ list \
   CONFIG.FlowControl {Blocking} \
   CONFIG.OutTready {true} \
   CONFIG.clocks_per_division {1} \
   CONFIG.dividend_and_quotient_width {64} \
   CONFIG.divisor_width {64} \
   CONFIG.fractional_width {64} \
   CONFIG.latency {135} \
   CONFIG.remainder_type {Fractional} \
 ] $div_gen_1

  # Create instance: div_gen_2, and set properties
  set div_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:div_gen:5.1 div_gen_2 ]
  set_property -dict [ list \
   CONFIG.FlowControl {Blocking} \
   CONFIG.OutTready {true} \
   CONFIG.clocks_per_division {1} \
   CONFIG.dividend_and_quotient_width {64} \
   CONFIG.divisor_width {64} \
   CONFIG.fractional_width {64} \
   CONFIG.latency {135} \
   CONFIG.remainder_type {Fractional} \
 ] $div_gen_2

  # Create instance: div_gen_3, and set properties
  set div_gen_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:div_gen:5.1 div_gen_3 ]
  set_property -dict [ list \
   CONFIG.FlowControl {Blocking} \
   CONFIG.OutTready {true} \
   CONFIG.clocks_per_division {1} \
   CONFIG.dividend_and_quotient_width {64} \
   CONFIG.divisor_width {64} \
   CONFIG.fractional_width {64} \
   CONFIG.latency {135} \
   CONFIG.remainder_type {Fractional} \
 ] $div_gen_3

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {4096} \
   CONFIG.C_NUM_OF_PROBES {19} \
   CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4LITE} \
 ] $ila_0

  # Create instance: ila_1, and set properties
  set ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_1 ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {4096} \
   CONFIG.C_ENABLE_ILA_AXI_MON {false} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {1} \
   CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4LITE} \
 ] $ila_1

  # Create instance: irfft_0, and set properties
  set irfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 irfft_0 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.output_ordering {natural_order} \
   CONFIG.phase_factor_width {32} \
   CONFIG.transform_length {4096} \
 ] $irfft_0

  # Create instance: irfft_1, and set properties
  set irfft_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 irfft_1 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.output_ordering {natural_order} \
   CONFIG.phase_factor_width {32} \
   CONFIG.transform_length {4096} \
 ] $irfft_1

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {650.000000} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.096154} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {650} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {26} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {100000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1300.000} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {52} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {21} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1050.000} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x0FFFFFFF} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {0} \
   CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_EMIO_ENET0 {0} \
   CONFIG.PCW_EN_EMIO_I2C0 {1} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_I2C0 {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_UART0 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {1} \
   CONFIG.PCW_I2C0_GRP_INT_IO {EMIO} \
   CONFIG.PCW_I2C0_I2C0_IO {EMIO} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {108.333336} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {20} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {in} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {out} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {enabled} \
   CONFIG.PCW_MIO_16_SLEW {slow} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {enabled} \
   CONFIG.PCW_MIO_17_SLEW {slow} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {enabled} \
   CONFIG.PCW_MIO_18_SLEW {slow} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {enabled} \
   CONFIG.PCW_MIO_19_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {inout} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {enabled} \
   CONFIG.PCW_MIO_20_SLEW {slow} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {enabled} \
   CONFIG.PCW_MIO_21_SLEW {slow} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {enabled} \
   CONFIG.PCW_MIO_22_SLEW {slow} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {enabled} \
   CONFIG.PCW_MIO_23_SLEW {slow} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {enabled} \
   CONFIG.PCW_MIO_24_SLEW {slow} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {enabled} \
   CONFIG.PCW_MIO_25_SLEW {slow} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {enabled} \
   CONFIG.PCW_MIO_26_SLEW {slow} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {enabled} \
   CONFIG.PCW_MIO_27_SLEW {slow} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {slow} \
   CONFIG.PCW_MIO_29_DIRECTION {inout} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {inout} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {slow} \
   CONFIG.PCW_MIO_31_DIRECTION {inout} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {slow} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {slow} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {slow} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {slow} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {slow} \
   CONFIG.PCW_MIO_36_DIRECTION {inout} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {slow} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {slow} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {slow} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {inout} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {inout} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {inout} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {inout} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {inout} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {inout} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {inout} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO} \
   CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#gpio[1]#gpio[2]#gpio[3]#gpio[4]#gpio[5]#gpio[6]#gpio[7]#gpio[8]#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#gpio[28]#gpio[29]#gpio[30]#gpio[31]#gpio[32]#gpio[33]#gpio[34]#gpio[35]#gpio[36]#gpio[37]#gpio[38]#gpio[39]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#gpio[47]#gpio[48]#gpio[49]#gpio[50]#gpio[51]#gpio[52]#gpio[53]} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {525.000000} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {525} \
   CONFIG.PCW_USB0_RESET_ENABLE {0} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
 ] $processing_system7_0

  # Create instance: resig_rfft_0, and set properties
  set resig_rfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 resig_rfft_0 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.phase_factor_width {8} \
   CONFIG.transform_length {4096} \
 ] $resig_rfft_0

  # Create instance: resig_rfft_1, and set properties
  set resig_rfft_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 resig_rfft_1 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.phase_factor_width {8} \
   CONFIG.transform_length {4096} \
 ] $resig_rfft_1

  # Create instance: respeaker_stream_v1_0_0, and set properties
  set respeaker_stream_v1_0_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:respeaker_stream_v1_0:1.0 respeaker_stream_v1_0_0 ]

  # Create instance: sig_rfft_0, and set properties
  set sig_rfft_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 sig_rfft_0 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.phase_factor_width {8} \
   CONFIG.transform_length {4096} \
 ] $sig_rfft_0

  # Create instance: sig_rfft_1, and set properties
  set sig_rfft_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft:9.1 sig_rfft_1 ]
  set_property -dict [ list \
   CONFIG.implementation_options {radix_4_burst_io} \
   CONFIG.input_width {32} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {0} \
   CONFIG.phase_factor_width {8} \
   CONFIG.transform_length {4096} \
 ] $sig_rfft_1

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins axis_compare_0/s00_axi]
connect_bd_intf_net -intf_net [get_bd_intf_nets axi_interconnect_0_M00_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins ila_0/SLOT_0_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net axis_acc_convert_0_m00_axis [get_bd_intf_pins axis_acc_convert_0/m00_axis] [get_bd_intf_pins irfft_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_acc_convert_1_m00_axis [get_bd_intf_pins axis_acc_convert_1/m00_axis] [get_bd_intf_pins irfft_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_bram_4_channel_0_m00_axis [get_bd_intf_pins axis_bram_4_channel_0/m00_axis] [get_bd_intf_pins sig_rfft_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_bram_4_channel_0_m01_axis [get_bd_intf_pins axis_bram_4_channel_0/m01_axis] [get_bd_intf_pins resig_rfft_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_bram_4_channel_0_m02_axis [get_bd_intf_pins axis_bram_4_channel_0/m02_axis] [get_bd_intf_pins sig_rfft_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_bram_4_channel_0_m03_axis [get_bd_intf_pins axis_bram_4_channel_0/m03_axis] [get_bd_intf_pins resig_rfft_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_fft_config_0_m00_axis [get_bd_intf_pins axis_fft_config_0/m00_axis] [get_bd_intf_pins sig_rfft_1/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_fft_config_0_m01_axis [get_bd_intf_pins axis_fft_config_0/m01_axis] [get_bd_intf_pins resig_rfft_0/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_fft_config_0_m02_axis [get_bd_intf_pins axis_fft_config_0/m02_axis] [get_bd_intf_pins resig_rfft_1/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_fft_config_0_m03_axis [get_bd_intf_pins axis_fft_config_0/m03_axis] [get_bd_intf_pins sig_rfft_0/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_fft_config_0_m04_axis [get_bd_intf_pins axis_fft_config_0/m04_axis] [get_bd_intf_pins irfft_0/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_fft_config_0_m05_axis [get_bd_intf_pins axis_fft_config_0/m05_axis] [get_bd_intf_pins irfft_1/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_inverse_number_0_m00_axis [get_bd_intf_pins axis_inverse_number_0/m00_axis] [get_bd_intf_pins cmpy_0/S_AXIS_A]
  connect_bd_intf_net -intf_net axis_inverse_number_1_m00_axis [get_bd_intf_pins axis_inverse_number_1/m00_axis] [get_bd_intf_pins cmpy_0/S_AXIS_B]
  connect_bd_intf_net -intf_net axis_inverse_number_2_m00_axis [get_bd_intf_pins axis_inverse_number_2/m00_axis] [get_bd_intf_pins cmpy_1/S_AXIS_A]
  connect_bd_intf_net -intf_net axis_inverse_number_3_m00_axis [get_bd_intf_pins axis_inverse_number_3/m00_axis] [get_bd_intf_pins cmpy_1/S_AXIS_B]
  connect_bd_intf_net -intf_net axis_msr_keep_0_m00_axis [get_bd_intf_pins axis_msr_keep_0/m00_axis] [get_bd_intf_pins div_gen_0/S_AXIS_DIVISOR]
  connect_bd_intf_net -intf_net axis_msr_keep_0_m01_axis [get_bd_intf_pins axis_msr_keep_0/m01_axis] [get_bd_intf_pins div_gen_0/S_AXIS_DIVIDEND]
  connect_bd_intf_net -intf_net axis_msr_keep_0_m02_axis [get_bd_intf_pins axis_msr_keep_0/m02_axis] [get_bd_intf_pins div_gen_1/S_AXIS_DIVIDEND]
  connect_bd_intf_net -intf_net axis_msr_keep_0_m03_axis [get_bd_intf_pins axis_msr_keep_0/m03_axis] [get_bd_intf_pins div_gen_1/S_AXIS_DIVISOR]
  connect_bd_intf_net -intf_net axis_msr_keep_1_m00_axis [get_bd_intf_pins axis_msr_keep_1/m00_axis] [get_bd_intf_pins div_gen_2/S_AXIS_DIVISOR]
  connect_bd_intf_net -intf_net axis_msr_keep_1_m01_axis [get_bd_intf_pins axis_msr_keep_1/m01_axis] [get_bd_intf_pins div_gen_2/S_AXIS_DIVIDEND]
  connect_bd_intf_net -intf_net axis_msr_keep_1_m02_axis [get_bd_intf_pins axis_msr_keep_1/m02_axis] [get_bd_intf_pins div_gen_3/S_AXIS_DIVIDEND]
  connect_bd_intf_net -intf_net axis_msr_keep_1_m03_axis [get_bd_intf_pins axis_msr_keep_1/m03_axis] [get_bd_intf_pins div_gen_3/S_AXIS_DIVISOR]
  connect_bd_intf_net -intf_net cmpy_0_M_AXIS_DOUT [get_bd_intf_pins axis_msr_keep_0/s00_axis] [get_bd_intf_pins cmpy_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net cmpy_1_M_AXIS_DOUT [get_bd_intf_pins axis_msr_keep_1/s00_axis] [get_bd_intf_pins cmpy_1/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net div_gen_0_M_AXIS_DOUT [get_bd_intf_pins axis_acc_convert_0/s00_axis] [get_bd_intf_pins div_gen_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net div_gen_1_M_AXIS_DOUT [get_bd_intf_pins axis_acc_convert_0/s01_axis] [get_bd_intf_pins div_gen_1/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net div_gen_2_M_AXIS_DOUT [get_bd_intf_pins axis_acc_convert_1/s00_axis] [get_bd_intf_pins div_gen_2/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net div_gen_3_M_AXIS_DOUT [get_bd_intf_pins axis_acc_convert_1/s01_axis] [get_bd_intf_pins div_gen_3/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net irfft_0_M_AXIS_DATA [get_bd_intf_pins axis_compare_0/s00_axis] [get_bd_intf_pins irfft_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net irfft_1_M_AXIS_DATA [get_bd_intf_pins axis_compare_0/s01_axis] [get_bd_intf_pins irfft_1/M_AXIS_DATA]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR_0] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO_0] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_IIC_0 [get_bd_intf_ports IIC_0_0] [get_bd_intf_pins processing_system7_0/IIC_0]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net resig_rfft_0_M_AXIS_DATA [get_bd_intf_pins axis_inverse_number_1/s00_axis] [get_bd_intf_pins resig_rfft_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net resig_rfft_1_M_AXIS_DATA [get_bd_intf_pins axis_inverse_number_3/s00_axis] [get_bd_intf_pins resig_rfft_1/M_AXIS_DATA]
  connect_bd_intf_net -intf_net respeaker_stream_v1_0_0_m00_axis [get_bd_intf_pins axis_bram_4_channel_0/s00_axis] [get_bd_intf_pins respeaker_stream_v1_0_0/m00_axis]
  connect_bd_intf_net -intf_net sig_rfft_0_M_AXIS_DATA [get_bd_intf_pins axis_inverse_number_0/s00_axis] [get_bd_intf_pins sig_rfft_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net sig_rfft_1_M_AXIS_DATA [get_bd_intf_pins axis_inverse_number_2/s00_axis] [get_bd_intf_pins sig_rfft_1/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net I2S_i_0_1 [get_bd_ports I2S_i_0] [get_bd_pins respeaker_stream_v1_0_0/I2S_i]
  connect_bd_net -net axis_bram_4_channel_0_all_close [get_bd_pins axis_bram_4_channel_0/all_close] [get_bd_pins axis_inverse_number_0/all_close] [get_bd_pins axis_inverse_number_1/all_close] [get_bd_pins axis_inverse_number_2/all_close] [get_bd_pins axis_inverse_number_3/all_close]
  connect_bd_net -net axis_compare_0_compare_irq [get_bd_pins axi_gpio_0/gpio_io_i] [get_bd_pins axis_compare_0/compare_irq] [get_bd_pins ila_1/probe0]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axis_acc_convert_0/axis_aclk] [get_bd_pins axis_acc_convert_1/axis_aclk] [get_bd_pins axis_bram_4_channel_0/m00_axis_aclk] [get_bd_pins axis_bram_4_channel_0/m01_axis_aclk] [get_bd_pins axis_bram_4_channel_0/m02_axis_aclk] [get_bd_pins axis_bram_4_channel_0/m03_axis_aclk] [get_bd_pins axis_bram_4_channel_0/s00_axis_aclk] [get_bd_pins axis_compare_0/axis_aclk] [get_bd_pins axis_compare_0/s00_axi_aclk] [get_bd_pins axis_fft_config_0/aclk] [get_bd_pins axis_inverse_number_0/m00_axis_aclk] [get_bd_pins axis_inverse_number_0/s00_axis_aclk] [get_bd_pins axis_inverse_number_1/m00_axis_aclk] [get_bd_pins axis_inverse_number_1/s00_axis_aclk] [get_bd_pins axis_inverse_number_2/m00_axis_aclk] [get_bd_pins axis_inverse_number_2/s00_axis_aclk] [get_bd_pins axis_inverse_number_3/m00_axis_aclk] [get_bd_pins axis_inverse_number_3/s00_axis_aclk] [get_bd_pins axis_msr_keep_0/s00_axis_aclk] [get_bd_pins axis_msr_keep_1/s00_axis_aclk] [get_bd_pins cmpy_0/aclk] [get_bd_pins cmpy_1/aclk] [get_bd_pins div_gen_0/aclk] [get_bd_pins div_gen_1/aclk] [get_bd_pins div_gen_2/aclk] [get_bd_pins div_gen_3/aclk] [get_bd_pins ila_0/clk] [get_bd_pins ila_1/clk] [get_bd_pins irfft_0/aclk] [get_bd_pins irfft_1/aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins resig_rfft_0/aclk] [get_bd_pins resig_rfft_1/aclk] [get_bd_pins respeaker_stream_v1_0_0/m00_axis_aclk] [get_bd_pins sig_rfft_0/aclk] [get_bd_pins sig_rfft_1/aclk]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axis_acc_convert_0/axis_aresetn] [get_bd_pins axis_acc_convert_1/axis_aresetn] [get_bd_pins axis_bram_4_channel_0/m00_axis_aresetn] [get_bd_pins axis_bram_4_channel_0/m01_axis_aresetn] [get_bd_pins axis_bram_4_channel_0/m02_axis_aresetn] [get_bd_pins axis_bram_4_channel_0/m03_axis_aresetn] [get_bd_pins axis_bram_4_channel_0/s00_axis_aresetn] [get_bd_pins axis_compare_0/axis_aresetn] [get_bd_pins axis_compare_0/s00_axi_aresetn] [get_bd_pins axis_fft_config_0/aresetn] [get_bd_pins axis_inverse_number_0/m00_axis_aresetn] [get_bd_pins axis_inverse_number_0/s00_axis_aresetn] [get_bd_pins axis_inverse_number_1/m00_axis_aresetn] [get_bd_pins axis_inverse_number_1/s00_axis_aresetn] [get_bd_pins axis_inverse_number_2/m00_axis_aresetn] [get_bd_pins axis_inverse_number_2/s00_axis_aresetn] [get_bd_pins axis_inverse_number_3/m00_axis_aresetn] [get_bd_pins axis_inverse_number_3/s00_axis_aresetn] [get_bd_pins axis_msr_keep_0/s00_axis_aresetn] [get_bd_pins axis_msr_keep_1/s00_axis_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins respeaker_stream_v1_0_0/m00_axis_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axis_inverse_number_0/enable] [get_bd_pins axis_inverse_number_2/enable] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins axis_inverse_number_1/enable] [get_bd_pins axis_inverse_number_3/enable] [get_bd_pins xlconstant_1/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axis_compare_0/s00_axi/reg0] SEG_axis_compare_0_reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


