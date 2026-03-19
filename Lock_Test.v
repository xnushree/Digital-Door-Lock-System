module Lock_Test;

reg clk, reset, in;
wire unlock, alarm;
wire [1:0] attempts; 

Lock_Code uut(
    .clk(clk),
    .reset(reset),
    .in(in),
    .unlock(unlock),
    .alarm(alarm),
    .attempts(attempts)
);

// Clock
always #5 clk = ~clk;

initial begin
    clk = 0; reset = 1; in = 0;
    #10 reset = 0;

    // correct sequence
    #10 in = 1;
    #10 in = 0;
    #10 in = 1;
    #10 in = 1;

    #20;

    // first wrong attempt
    #10 in = 0;
    #10 in = 1;
    #10 in = 0;

    #20;

    // second wrong attempt
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;

    #20;

    // third wrong attempt
    #10 in = 1;
    #10 in = 0;
    #10 in = 0;

    #30;

    // reset
    reset = 1;
    #10 reset = 0;

    #20;

    // test for overlapping sequence
    #10 in = 1;
    #10 in = 0;
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;
    #10 in = 1;
    #10 in = 0;
    #10 in = 1;
    #10 in = 1;
    #10 in = 0;
    #10 in = 1;
    #10 in = 1;

    #50;

    $finish;
end

endmodule