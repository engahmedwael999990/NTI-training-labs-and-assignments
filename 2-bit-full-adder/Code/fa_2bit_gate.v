module fa_2bit_gate (
    input [1:0] a,
    input [1:0] b,
    input cin,
    output [1:0] sum,
    output cout
);
    wire w1, w2, w3; 
    wire c1;         
    wire w4, w5, w6; 

    xor (w1, a[0], b[0]);
    xor (sum[0], w1, cin);
    and (w2, a[0], b[0]);
    and (w3, w1, cin);
    or  (c1, w2, w3);


    xor (w4, a[1], b[1]);
    xor (sum[1], w4, c1);
    and (w5, a[1], b[1]);
    and (w6, w4, c1);
    or  (cout, w5, w6);

endmodule