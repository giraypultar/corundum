/*

Copyright (c) 2021 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * Statistics for AXI DMA interface
 */
module stats_dma_if_axi #
(
    // Length field width
    parameter LEN_WIDTH = 16,
    // Operation table size (read)
    parameter READ_OP_TABLE_SIZE = 64,
    // Operation table size (write)
    parameter WRITE_OP_TABLE_SIZE = 64,
    // Statistics counter increment width (bits)
    parameter STAT_INC_WIDTH = 24,
    // Statistics counter ID width (bits)
    parameter STAT_ID_WIDTH = 5,
    // Statistics counter update period (cycles)
    parameter UPDATE_PERIOD = 1024
)
(
    input  wire                                   clk,
    input  wire                                   rst,

    /*
     * Statistics from dma_if_axi
     */
    input wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_op_start_tag,
    input wire [LEN_WIDTH-1:0]                    stat_rd_op_start_len,
    input wire                                    stat_rd_op_start_valid,
    input wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_op_finish_tag,
    input wire [3:0]                              stat_rd_op_finish_status,
    input wire                                    stat_rd_op_finish_valid,
    input wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_req_start_tag,
    input wire [12:0]                             stat_rd_req_start_len,
    input wire                                    stat_rd_req_start_valid,
    input wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_req_finish_tag,
    input wire [3:0]                              stat_rd_req_finish_status,
    input wire                                    stat_rd_req_finish_valid,
    input wire                                    stat_rd_op_table_full,
    input wire                                    stat_rd_tx_stall,
    input wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_op_start_tag,
    input wire [LEN_WIDTH-1:0]                    stat_wr_op_start_len,
    input wire                                    stat_wr_op_start_valid,
    input wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_op_finish_tag,
    input wire [3:0]                              stat_wr_op_finish_status,
    input wire                                    stat_wr_op_finish_valid,
    input wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_req_start_tag,
    input wire [12:0]                             stat_wr_req_start_len,
    input wire                                    stat_wr_req_start_valid,
    input wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_req_finish_tag,
    input wire [3:0]                              stat_wr_req_finish_status,
    input wire                                    stat_wr_req_finish_valid,
    input wire                                    stat_wr_op_table_full,
    input wire                                    stat_wr_tx_stall,

    /*
     * Statistics output
     */
    output wire [STAT_INC_WIDTH-1:0]              m_axis_stat_tdata,
    output wire [STAT_ID_WIDTH-1:0]               m_axis_stat_tid,
    output wire                                   m_axis_stat_tvalid,
    input  wire                                   m_axis_stat_tready,

    /*
     * Control inputs
     */
    input  wire                                   update
);

wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_op_tag;
wire [LEN_WIDTH-1:0]                    stat_rd_op_len;
wire [3:0]                              stat_rd_op_status;
wire [15:0]                             stat_rd_op_latency;
wire                                    stat_rd_op_valid;
wire [$clog2(READ_OP_TABLE_SIZE)-1:0]   stat_rd_req_tag;
wire [12:0]                             stat_rd_req_len;
wire [3:0]                              stat_rd_req_status;
wire [15:0]                             stat_rd_req_latency;
wire                                    stat_rd_req_valid;
wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_op_tag;
wire [LEN_WIDTH-1:0]                    stat_wr_op_len;
wire [3:0]                              stat_wr_op_status;
wire [15:0]                             stat_wr_op_latency;
wire                                    stat_wr_op_valid;
wire [$clog2(WRITE_OP_TABLE_SIZE)-1:0]  stat_wr_req_tag;
wire [12:0]                             stat_wr_req_len;
wire [3:0]                              stat_wr_req_status;
wire [15:0]                             stat_wr_req_latency;
wire                                    stat_wr_req_valid;

stats_dma_latency #(
    .COUNT_WIDTH(16),
    .TAG_WIDTH($clog2(READ_OP_TABLE_SIZE)),
    .LEN_WIDTH(LEN_WIDTH),
    .STATUS_WIDTH(4)
)
stats_dma_latency_rd_op_inst (
    .clk(clk),
    .rst(rst),

    /*
     * Tag inputs
     */
    .in_start_tag(stat_rd_op_start_tag),
    .in_start_len(stat_rd_op_start_len),
    .in_start_valid(stat_rd_op_start_valid),
    .in_finish_tag(stat_rd_op_finish_tag),
    .in_finish_status(stat_rd_op_finish_status),
    .in_finish_valid(stat_rd_op_finish_valid),

    /*
     * Statistics increment output
     */
    .out_tag(stat_rd_op_tag),
    .out_len(stat_rd_op_len),
    .out_status(stat_rd_op_status),
    .out_latency(stat_rd_op_latency),
    .out_valid(stat_rd_op_valid)
);

stats_dma_latency #(
    .COUNT_WIDTH(16),
    .TAG_WIDTH($clog2(READ_OP_TABLE_SIZE)),
    .LEN_WIDTH(13),
    .STATUS_WIDTH(4)
)
stats_dma_latency_rd_req_inst (
    .clk(clk),
    .rst(rst),

    /*
     * Tag inputs
     */
    .in_start_tag(stat_rd_req_start_tag),
    .in_start_len(stat_rd_req_start_len),
    .in_start_valid(stat_rd_req_start_valid),
    .in_finish_tag(stat_rd_req_finish_tag),
    .in_finish_status(stat_rd_req_finish_status),
    .in_finish_valid(stat_rd_req_finish_valid),

    /*
     * Statistics increment output
     */
    .out_tag(stat_rd_req_tag),
    .out_len(stat_rd_req_len),
    .out_status(stat_rd_req_status),
    .out_latency(stat_rd_req_latency),
    .out_valid(stat_rd_req_valid)
);

stats_dma_latency #(
    .COUNT_WIDTH(16),
    .TAG_WIDTH($clog2(WRITE_OP_TABLE_SIZE)),
    .LEN_WIDTH(LEN_WIDTH),
    .STATUS_WIDTH(4)
)
stats_dma_latency_wr_op_inst (
    .clk(clk),
    .rst(rst),

    /*
     * Tag inputs
     */
    .in_start_tag(stat_wr_op_start_tag),
    .in_start_len(stat_wr_op_start_len),
    .in_start_valid(stat_wr_op_start_valid),
    .in_finish_tag(stat_wr_op_finish_tag),
    .in_finish_status(stat_wr_op_finish_status),
    .in_finish_valid(stat_wr_op_finish_valid),

    /*
     * Statistics increment output
     */
    .out_tag(stat_wr_op_tag),
    .out_len(stat_wr_op_len),
    .out_status(stat_wr_op_status),
    .out_latency(stat_wr_op_latency),
    .out_valid(stat_wr_op_valid)
);

stats_dma_latency #(
    .COUNT_WIDTH(16),
    .TAG_WIDTH($clog2(WRITE_OP_TABLE_SIZE)),
    .LEN_WIDTH(13),
    .STATUS_WIDTH(4)
)
stats_dma_latency_wr_req_inst (
    .clk(clk),
    .rst(rst),

    /*
     * Tag inputs
     */
    .in_start_tag(stat_wr_req_start_tag),
    .in_start_len(stat_wr_req_start_len),
    .in_start_valid(stat_wr_req_start_valid),
    .in_finish_tag(stat_wr_req_finish_tag),
    .in_finish_status(stat_wr_req_finish_status),
    .in_finish_valid(stat_wr_req_finish_valid),

    /*
     * Statistics increment output
     */
    .out_tag(stat_wr_req_tag),
    .out_len(stat_wr_req_len),
    .out_status(stat_wr_req_status),
    .out_latency(stat_wr_req_latency),
    .out_valid(stat_wr_req_valid)
);

wire [15:0] stat_rd_op_count_inc = stat_rd_op_valid;
wire [15:0] stat_rd_op_bytes_inc = stat_rd_op_len;
wire [15:0] stat_rd_op_latency_inc = stat_rd_op_latency;
wire [15:0] stat_rd_op_error_inc = stat_rd_op_valid && (stat_rd_op_status != 0);
wire [15:0] stat_rd_req_count_inc = stat_rd_req_valid;
wire [15:0] stat_rd_req_latency_inc = stat_rd_req_latency;
wire [15:0] stat_rd_op_table_full_inc = stat_rd_op_table_full;
wire [15:0] stat_rd_tx_stall_inc = stat_rd_tx_stall;

wire [15:0] stat_wr_op_count_inc = stat_wr_op_valid;
wire [15:0] stat_wr_op_bytes_inc = stat_wr_op_len;
wire [15:0] stat_wr_op_latency_inc = stat_wr_op_latency;
wire [15:0] stat_wr_op_error_inc = stat_wr_op_valid && (stat_wr_op_status != 0);
wire [15:0] stat_wr_req_count_inc = stat_wr_req_valid;
wire [15:0] stat_wr_req_latency_inc = stat_wr_req_latency;
wire [15:0] stat_wr_op_table_full_inc = stat_wr_op_table_full;
wire [15:0] stat_wr_tx_stall_inc = stat_wr_tx_stall;

stats_collect #(
    .COUNT(32),
    .INC_WIDTH(16),
    .STAT_INC_WIDTH(STAT_INC_WIDTH),
    .STAT_ID_WIDTH(5),
    .UPDATE_PERIOD(UPDATE_PERIOD)
)
stats_collect_tx_inst (
    .clk(clk),
    .rst(rst),

    /*
     * Increment inputs
     */
    .stat_inc({
        16'd0,                     // index 31
        16'd0,                     // index 30
        16'd0,                     // index 29
        16'd0,                     // index 28
        stat_wr_tx_stall_inc,      // index 27
        16'd0,                     // index 26
        16'd0,                     // index 25
        16'd0,                     // index 24
        stat_wr_op_table_full_inc, // index 23
        16'd0,                     // index 22
        stat_wr_req_latency_inc,   // index 21
        stat_wr_req_count_inc,     // index 20
        stat_wr_op_error_inc,      // index 19
        stat_wr_op_latency_inc,    // index 18
        stat_wr_op_bytes_inc,      // index 17
        stat_wr_op_count_inc,      // index 16
        16'd0,                     // index 15
        16'd0,                     // index 14
        16'd0,                     // index 13
        16'd0,                     // index 12
        stat_rd_tx_stall_inc,      // index 11
        16'd0,                     // index 10
        16'd0,                     // index 9
        16'd0,                     // index 8
        stat_rd_op_table_full_inc, // index 7
        16'd0,                     // index 6
        stat_rd_req_latency_inc,   // index 5
        stat_rd_req_count_inc,     // index 4
        stat_rd_op_error_inc,      // index 3
        stat_rd_op_latency_inc,    // index 2
        stat_rd_op_bytes_inc,      // index 1
        stat_rd_op_count_inc       // index 0
    }),
    .stat_valid({32{1'b1}}),

    /*
     * Statistics increment output
     */
    .m_axis_stat_tdata(m_axis_stat_tdata),
    .m_axis_stat_tid(m_axis_stat_tid),
    .m_axis_stat_tvalid(m_axis_stat_tvalid),
    .m_axis_stat_tready(m_axis_stat_tready),

    /*
     * Control inputs
     */
    .update(update)
);

endmodule

`resetall
