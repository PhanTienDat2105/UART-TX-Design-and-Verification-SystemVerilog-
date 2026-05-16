`timescale 1ns / 1ps

module UART_TX(
input logic clk,
input logic rst,
input logic [7:0] data_in,
input logic valid,

output logic tx,
output logic busy
    );
logic [7:0] shift_reg;
logic [2:0] count;

typedef enum logic [1:0] {
IDLE, START, DATA, STOP
} state_t;
state_t state, next_state;


//Khối register
always_ff@(posedge clk or posedge rst) begin
if(rst) state <= IDLE;
else state <= next_state;
end

// KHối next state logic
always_comb begin
next_state = state;
case(state)
IDLE: begin 
if(valid) begin next_state = START; end
else begin next_state = IDLE; end 
end

START: begin next_state = DATA; end

DATA: begin 
if(count == 3'd7) begin  next_state = STOP; end
end

STOP: begin next_state = IDLE;
end
default:  next_state = IDLE;
endcase
end

// Khối output logic
always_ff@(posedge clk or posedge rst) begin
if(rst) begin 
tx <= 1'b1;
shift_reg <= 8'b0;
count <= 3'b0;
busy <= 0;
end
else begin

case(state)
IDLE: begin 
tx <= 1;
count <= 3'b0;
busy <= 0;
if(valid) begin 
shift_reg <= data_in;
busy <= 1;
end
end

START: begin 
tx <= 1'b0;
busy <= 1'b1;
 end

DATA: begin 
tx <= shift_reg[0];
shift_reg <= shift_reg >> 1;
busy <= 1'b1;
 count <= count +1;
end

STOP: begin 
count <= 3'b0;
tx <= 1'b1;
busy <= 1'b0; 
end
endcase
end
end
endmodule
