module full_adder (
    input a, 
    input b, 
    input cin,
    output sum, 
    output cout
);
    wire ha1_sum, ha1_cout, ha2_cout;

    half_adder HA1 (.a(a), .b(b), .sum(ha1_sum), .cout(ha1_cout));
    half_adder HA2 (.a(ha1_sum), .b(cin), .sum(sum), .cout(ha2_cout));
    
    or (cout, ha1_cout, ha2_cout);
endmodule