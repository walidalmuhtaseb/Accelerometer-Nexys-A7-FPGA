`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Walid Al-Muhtaseb
// 
// Create Date: 12/4/2025 01:54:30 PM
// Design Name: Accelerator Top Module
// Module Name: top
//////////////////////////////////////////////////////////////////////////////////

module merged_top(
    input CLK100MHZ,
    input BtnC,

    // Accelerometer SPI signals
    input ACL_MISO,
    output ACL_MOSI,
    output ACL_SCLK,
    output ACL_CSN,

    // VGA signals
    output hSync,
    output vSync,
    output [3:0] vgaR,
    output [3:0] vgaG,
    output [3:0] vgaB,

    // Seven Segment Display
    output [6:0] SEG,
    output DP,
    output [7:0] AN,

    // Optional LED Debug (X, Y, Z bits)
    output [14:0] LED
);

    // Accelerometer Data (X[14:10], Y[9:5], Z[4:0])
    wire [14:0] acl_data;

    // Clock generation
    wire clk_4MHz;
    iclk_gen clkgen (
        .CLK100MHZ(CLK100MHZ),
        .clk_4MHz(clk_4MHz)
    );

    // SPI Master to read accelerometer
    spi_master spi (
        .iclk(clk_4MHz),
        .miso(ACL_MISO),
        .mosi(ACL_MOSI),
        .sclk(ACL_SCLK),
        .cs(ACL_CSN),
        .acl_data(acl_data)
    );

    // Display accelerometer data on 7-segment display
    seg7_control sseg (
        .CLK100MHZ(CLK100MHZ),
        .acl_data(acl_data),
        .seg(SEG),
        .dp(DP),
        .an(AN)
    );

    // VGA Timing Generation
    wire bright;
    wire [9:0] hCount, vCount;
    display_controller vga_disp (
        .clk(CLK100MHZ),
        .hSync(hSync),
        .vSync(vSync),
        .bright(bright),
        .hCount(hCount),
        .vCount(vCount)
    );

    // Convert accelerometer sign bits to motion signals
    wire x_neg = acl_data[14];
    wire y_neg = acl_data[9];
    wire move_left  = x_neg;
    wire move_right = ~x_neg;
    wire move_down  = y_neg;
    wire move_up    = ~y_neg;

    // Generate a slower movement clock from divider
    reg [27:0] div_counter = 0;
    always @(posedge CLK100MHZ) begin
        div_counter <= div_counter + 1;
    end
    wire move_clk = div_counter[19];

    // RGB color output
    wire [11:0] rgb;
    wire [11:0] background;

    block_controller block_ctrl (
        .acl_data(acl_data),
        .clk(move_clk),
        .bright(bright),
        .rst(BtnC),
        .up(move_up),
        .down(move_down),
        .left(move_left),
        .right(move_right),
        .hCount(hCount),
        .vCount(vCount),
        .rgb(rgb),
        .background(background)
    );

    // VGA color mapping
    assign vgaR = rgb[11:8];
    assign vgaG = rgb[7:4];
    assign vgaB = rgb[3:0];

    // LED Debugging
    assign LED = acl_data;

endmodule
