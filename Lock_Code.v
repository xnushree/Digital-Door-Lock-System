module Lock_Code(
    input clk,
    input reset,
    input in,
    output unlock,
    output alarm,
    output [1:0] attempts  
);

wire wrong;
wire timeout;

fsm_lock fsm(
    .clk(clk),
    .reset(reset | timeout),
    .in(in),
    .unlock(unlock),
    .wrong(wrong)
);

attempt_counter counter(
    .clk(clk),
    .reset(reset | unlock),
    .wrong(wrong),
    .attempts(attempts),
    .alarm(alarm)
);

timer t1(
    .clk(clk),
    .enable(1'b1),
    .timeout(timeout)
);

endmodule

//FSM Logic
module fsm_lock(
    input clk,
    input reset,
    input in,
    output reg unlock,
    output reg wrong
);

reg [2:0] state, next_state;

parameter S0=3'd0, S1=3'd1, S2=3'd2, S3=3'd3, S4=3'd4;

// State register
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= S0;
    else
        state <= next_state;
end

// Next state logic
always @(*) begin
    wrong = 0;
    case(state)
        S0: next_state = (in) ? S1 : S0;

        S1: next_state = (in==0) ? S2 : S1;

        S2: begin
            if (in==1) next_state = S3;
            else begin next_state = S0; wrong = 1; end
        end

        S3: begin
            if (in==1) next_state = S4;
            else next_state = S2; // deals with overlapping sequence
        end

        S4: next_state = S0;

        default: next_state = S0;
    endcase
end

// Output
always @(*) begin
    unlock = (state == S4);
end

endmodule

// counter to record number of wrong attemps
module attempt_counter(
    input clk,
    input reset,
    input wrong,
    output reg [1:0] attempts,
    output reg alarm
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        attempts <= 0;
        alarm <= 0;
    end
    else if (wrong) begin
        if (attempts < 3)
            attempts <= attempts + 1;

        if (attempts == 2) // 3rd wrong
            alarm <= 1;
    end
end

endmodule

module timer(
    input clk,
    input enable,
    output reg timeout
);

reg [31:0] count;

always @(posedge clk) begin
    if (enable) begin
        count <= count + 1;
        if (count == 50)
            timeout <= 1;
    end else begin
        count <= 0;
        timeout <= 0;
    end
end

endmodule