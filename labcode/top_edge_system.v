module top_edge_system #(
    parameter CLK_DIV_TOGGLE = 250000
)(
    input  wire clk_50M,
    input  wire rst_n,
    input  wire in_sig,
    output wire [6:0] seg_r, seg_rc,
    output wire [6:0] seg_f, seg_fc,
    output wire [6:0] seg_t, seg_tc
);
    wire clk_100Hz;
    wire r_tick, f_tick, e_tick;
    wire [3:0] r_cnt, f_cnt, t_cnt;

    // 1. Clock Divider
    clk_div_100hz #(.TOGGLE_COUNT(CLK_DIV_TOGGLE)) u_clk_div (
        .clk_50M(clk_50M), .rst_n(rst_n), .clk_100Hz(clk_100Hz)
    );

    // 2. Edge Detector
    edge_detector u_edge_det (
        .clk_100Hz(clk_100Hz), .rst_n(rst_n), .in_sig(in_sig),
        .rise_tick(r_tick), .fall_tick(f_tick), .edge_tick(e_tick)
    );

    // 3. Edge Counter
    edge_counter u_edge_cnt (
        .clk_100Hz(clk_100Hz), .rst_n(rst_n), 
        .rise_tick(r_tick), .fall_tick(f_tick), .edge_tick(e_tick),
        .rise_count(r_cnt), .fall_count(f_cnt), .total_count(t_cnt)
    );

    // 4. Hex Decoder 
    hex_6seg_decoder u_hex_dec (
        .rst_n(rst_n), .rise_count(r_cnt), .fall_count(f_cnt), .total_count(t_cnt),
        .seg_r(seg_r), .seg_rc(seg_rc), .seg_f(seg_f), .seg_fc(seg_fc), .seg_t(seg_t), .seg_tc(seg_tc)
    );
endmodule