`timescale 1ns / 1ps

//==================================================
// TRANSACTION
//==================================================
class uart_txn;
    rand bit [7:0] data_in;
    function void display();
        $display("DATA = %b", data_in);
    endfunction
endclass
//==================================================
// GENERATOR
//==================================================
class generator;
    mailbox #(uart_txn) mbx;
    uart_txn tr;
    function new(mailbox #(uart_txn) mbx);
        this.mbx = mbx;
    endfunction
    task run();
        repeat(10) begin
            tr = new();
            if(!tr.randomize())
                $error("Randomization failed");
            tr.display();
            mbx.put(tr);
        end
    endtask
endclass

//==================================================
// TESTBENCH
//==================================================
module tb;
logic clk;
logic rst;
logic [7:0] data_in;
logic valid;
logic tx;
logic busy;

//==================================================
// MAILBOX + OBJECTS
//==================================================
mailbox #(uart_txn) mbx;
generator gen;
uart_txn tr;
//==================================================
// DUT
//==================================================
UART_TX dut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid(valid),
    .tx(tx),
    .busy(busy)
);
//==================================================
// CLOCK
//==================================================
always #5 clk = ~clk;
//==================================================
// DRIVER
//==================================================
task driver();
    forever begin
        mbx.get(tr);
        @(posedge clk);
        data_in <= tr.data_in;
        valid   <= 1'b1;
        @(posedge clk);
        valid <= 1'b0;
        // wait transmission complete
        repeat(12) @(posedge clk);
    end
endtask
//==================================================
// ASSERTIONS
//==================================================
// valid should trigger busy
property p_valid_to_busy;

    @(posedge clk)
    valid |=> busy;
endproperty

assert property (p_valid_to_busy)
else
    $error("ASSERTION FAILED: valid did not trigger busy");

// START bit must be LOW
property p_start_bit;

    @(posedge clk)
    busy && !$past(busy) |=> tx == 1'b0;

endproperty

assert property (p_start_bit)
else
    $error("ASSERTION FAILED: START bit is not LOW");
// transmission must finish
property p_transmission_finish;

    @(posedge clk)
    valid |-> ##[1:15] !busy;

endproperty

assert property (p_transmission_finish)
else
    $error("ASSERTION FAILED: Transmission timeout");

//==================================================
// TEST SEQUENCE
//==================================================
initial begin
    mbx = new();
    gen = new(mbx);
    clk = 0;
    rst = 1;
    valid = 0;
    #20;
    rst = 0;
    fork
        gen.run();
        driver();
    join_none
    #2000;
    $finish;
end
endmodule
