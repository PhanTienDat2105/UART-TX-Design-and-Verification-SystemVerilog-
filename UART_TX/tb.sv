`timescale 1ns / 1ps

class uart_txn;

    rand bit [7:0] data_in;

    function void display();
        $display("DATA = %b", data_in);
    endfunction

endclass



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
                $error("Randomize failed");

            tr.display();

            mbx.put(tr);

        end

    endtask

endclass








module tb;

logic clk;
logic rst;
logic [7:0] data_in;
logic valid;

logic tx;
logic busy;

mailbox #(uart_txn) mbx;

generator gen;

uart_txn tr;


UART_TX dut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid(valid),
    .tx(tx),
    .busy(busy)
);


always #5 clk = ~clk;



task driver();

    forever begin

        mbx.get(tr);

        @(posedge clk);

        data_in <= tr.data_in;
        valid   <= 1'b1;

        @(posedge clk);

        valid <= 1'b0;

        repeat(12) @(posedge clk);

    end

endtask



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
property p_idle_tx_high;

    @(posedge clk)
    !busy |-> tx == 1'b1;

endproperty

assert property (p_idle_tx_high)
else
    $error("ASSERTION FAILED: TX must stay HIGH when IDLE");



// valid phải làm busy lên ở cycle sau
property p_valid_to_busy;

    @(posedge clk)
    valid |=> busy;

endproperty

assert property (p_valid_to_busy)
else
    $error("ASSERTION FAILED: valid did not trigger busy");



// Khi transmission bắt đầu -> start bit phải = 0
property p_start_bit;

    @(posedge clk)
    busy && !$past(busy) |=> tx == 1'b0;

endproperty

assert property (p_start_bit)
else
    $error("ASSERTION FAILED: START bit is not LOW");



// Sau valid thì transmission phải kết thúc
property p_transmission_finish;

    @(posedge clk)
    valid |-> ##[1:15] !busy;

endproperty

assert property (p_transmission_finish)
else
    $error("ASSERTION FAILED: Transmission timeout");
endmodule