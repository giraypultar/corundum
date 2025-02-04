# Timing constraints for the Intel Stratix 10 MX FPGA development board

set_time_format -unit ns -decimal_places 3

# Clock constraints
create_clock -period 20.000 -name {clk_sys_50m_p} [ get_ports {clk_sys_50m_p} ]
create_clock -period 10.000 -name {clk_sys_100m_p} [ get_ports {clk_sys_100m_p} ]
create_clock -period 10.000 -name {clk_core_bak_p} [ get_ports {clk_core_bak_p} ]
create_clock -period 10.000 -name {clk_uib0_p} [ get_ports {clk_uib0_p} ]
create_clock -period 10.000 -name {clk_uib1_p} [ get_ports {clk_uib1_p} ]
create_clock -period 10.000 -name {clk_esram0_p} [ get_ports {clk_esram0_p} ]
create_clock -period 10.000 -name {clk_esram1_p} [ get_ports {clk_esram1_p} ]
create_clock -period 7.500 -name {clk_ddr4_comp_p} [ get_ports {clk_ddr4_comp_p} ]
create_clock -period 7.500 -name {clk_ddr4_dimm_p} [ get_ports {clk_ddr4_dimm_p} ]

create_clock -period 10.000 -name {refclk_pcie_ep_p} [ get_ports {refclk_pcie_ep_p} ]
create_clock -period 10.000 -name {refclk_pcie_ep_edge_p} [ get_ports {refclk_pcie_ep_edge_p} ]
create_clock -period 10.000 -name {refclk_pcie_ep1_p} [ get_ports {refclk_pcie_ep1_p} ]
create_clock -period 10.000 -name {refclk_pcie_rp_p} [ get_ports {refclk_pcie_rp_p} ]

create_clock -period 1.551 -name {refclk_qsfp0_p} [ get_ports {refclk_qsfp0_p} ]
create_clock -period 1.551 -name {refclk_qsfp1_p} [ get_ports {refclk_qsfp1_p} ]

derive_clock_uncertainty

set_clock_groups -asynchronous -group [ get_clocks {clk_sys_50m_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_sys_100m_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_core_bak_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_uib0_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_uib1_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_esram0_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_esram1_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_ddr4_comp_p} ]
set_clock_groups -asynchronous -group [ get_clocks {clk_ddr4_dimm_p} ]

set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep_p} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep_edge_p} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_ep1_p} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_pcie_rp_p} ]

set_clock_groups -asynchronous -group [ get_clocks {refclk_qsfp0_p} ]
set_clock_groups -asynchronous -group [ get_clocks {refclk_qsfp1_p} ]

# JTAG constraints
create_clock -name {altera_reserved_tck} -period 40.800 {altera_reserved_tck}

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

# IO constraints
set_false_path -from "cpu_resetn"
set_false_path -to   "user_led[*]"

set_false_path -from "s10_pcie_perstn0"
set_false_path -from "s10_pcie_perstn1"


source ../lib/eth/syn/quartus_pro/eth_mac_fifo.sdc
source ../lib/eth/lib/axis/syn/quartus_pro/sync_reset.sdc
source ../lib/eth/lib/axis/syn/quartus_pro/axis_async_fifo.sdc

# clocking infrastructure
constrain_sync_reset_inst "sync_reset_100mhz_inst"
constrain_sync_reset_inst "ptp_rst_reset_sync_inst"

# PTP ref clock
set_clock_groups -asynchronous -group [ get_clocks {ref_div_inst|stratix10_clkctrl_0|clkdiv_inst|clock_div4} ]

# PHY clocks
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|eth_xcvr_inst|rx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|tx_clkout|ch0} ]
set_clock_groups -asynchronous -group [ get_clocks {qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|eth_xcvr_inst|rx_clkout|ch0} ]

# PHY resets
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp0_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_1|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_2|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_3|phy_rx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_tx_rst_reset_sync_inst"
constrain_sync_reset_inst "qsfp1_eth_xcvr_phy_quad|eth_xcvr_phy_4|phy_rx_rst_reset_sync_inst"

# 10G MAC
constrain_eth_mac_fifo_inst "core_inst|eth_mac_10g_fifo_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_10g_fifo_inst|rx_fifo|fifo_inst"
constrain_axis_async_fifo_inst "core_inst|eth_mac_10g_fifo_inst|tx_fifo|fifo_inst"
