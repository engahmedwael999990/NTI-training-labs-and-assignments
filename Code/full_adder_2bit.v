module full_adder_2bit (
    input [1:0] a,
    input [1:0] b,
    input cin,
    output [1:0] sum,
    output cout
);
    wire c1; 

    // Bit 0
    full_adder FA0 (
        .a(a[0]), .b(b[0]), .cin(cin),
        .sum(sum[0]), .cout(c1)
    );

    // Bit 1
    full_adder FA1 (
        .a(a[1]), .b(b[1]), .cin(c1),
        .sum(sum[1]), .cout(cout)
    );
endmodule