`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 16:53:44
// Design Name: 
// Module Name: sync4bitMul_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


import tb_pkg::*;

interface top_interface;
    logic [3:0] a,b;
    logic [7:0] mul;
    logic clk;
endinterface

module sync4bitMul_tb;
    Generator gen;
    Driver drv;
    monitor mon;
    scoreboard sco;
    top_interface tif();
    mailbox #(transaction) mbx_gen2drv;
    mailbox #(transaction) mbx_drv2mon;
    mailbox #(transaction) mbx_mon2sco;
    event done;
    sync4bitMul dut (.clk(tif.clk),.a(tif.a),.b(tif.b),.mul(tif.mul)); ///// From here, the interface gets the output of dut tests
    initial tif.clk = 0;
    always #10 tif.clk = ~tif.clk;
    initial begin
        mbx_gen2drv = new();
        mbx_drv2mon = new();
        mbx_mon2sco = new();
        gen = new(mbx_gen2drv);
        drv = new(mbx_gen2drv, mbx_drv2mon);
        mon = new(mbx_drv2mon, mbx_mon2sco);
        sco = new(mbx_mon2sco);
        drv.tif = tif; //// assigning interface tif from top level testbench to local driver's interface 
        done = gen.done; //// assigning local done to generator's done which will signal when stimulus generation is done
    end
    initial begin
        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join_none
        wait(done.triggered);
        #1000;
        $display("Finish");
        $finish;
    end

endmodule
