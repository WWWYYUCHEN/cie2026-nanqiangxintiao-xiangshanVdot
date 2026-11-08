`timescale 1ns/1ps
`default_nettype none

module vdot_exact_unit (
    input  wire [127:0] vs1,
    input  wire [127:0] vs2,
    output wire [127:0] vd
);
    integer k;
    reg signed [31:0] acc;
    reg signed [7:0] a;
    reg signed [7:0] b;
    reg signed [15:0] prod;

    always @* begin
        acc = 32'sd0;
        for (k = 0; k < 8; k = k + 1) begin
            a = vs1[8*k +: 8];
            b = vs2[8*k +: 8];
            prod = a * b;
            acc = acc + {{16{prod[15]}}, prod};
        end
    end

    assign vd = {96'd0, acc};
endmodule

`default_nettype wire
