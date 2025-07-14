`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2025 19:51:57
// Design Name: 
// Module Name: tb_pkg
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

package tb_pkg;
    class transaction;
        randc bit [3:0] a,b;
        bit [7:0] mul;
        // preparing for deep copy
        function transaction copy();
            copy = new();
            copy.a = this.a;
            copy.b = this.b;
            copy.mul = this.mul;
        endfunction
        function void display();
            $display( " input a : %0b , input b : %0b , output mul : %0b", a,b,mul);
        endfunction
    endclass
    
    class Generator;
        transaction t;
        mailbox #(transaction) mbx_gen2drv;
        function  new (mailbox #(transaction) mbx_gen2drv);
            this.mbx_gen2drv = mbx_gen2drv;
            t = new();
        endfunction
        event done;
        task run();
            for(int i=0;i<10;i++)begin
                assert(t.randomize()) else $display("Randomization unsucessful");
                $display ("[GEN] Data sent, i : %0d" , i);
                mbx_gen2drv.put(t.copy());
                #80;
            end
            -> done;
        endtask
    endclass
    
    //// In the driver, we'll be giving inputs from generator to interface, and taking putputs from dut to interface
    class Driver;
        transaction t;
        virtual top_interface tif; ///// WHY virtual  - ITS A RULE
        mailbox #(transaction) mbx_gen2drv , mbx_drv2mon;
        function new (mailbox #(transaction) mbx_gen2drv,mailbox #(transaction) mbx_drv2mon);
            this.mbx_gen2drv = mbx_gen2drv;
            this.mbx_drv2mon = mbx_drv2mon;
            t = new();
        endfunction
        task run();
            forever begin
                mbx_gen2drv.get(t);
                @(posedge tif.clk);
                    tif.a <= t.a;
                    tif.b <= t.b;
                repeat (2) @(posedge tif.clk); //// gives 1 cycle extra to get the outputs performed by DUT on the inputs just given
                    t.mul = tif.mul; ///// DUT output giving in transaction, later used in monitor (ALWAYS use blocking assignment)
                mbx_drv2mon.put(t.copy()); //// Sending the updated transaction with output of test, to monitor
            end
        endtask
    endclass    
    
    class monitor;
        transaction t;
        mailbox #(transaction) mbx_drv2mon;
        mailbox #(transaction) mbx_mon2sco;
        function  new( mailbox #(transaction) mbx_drv2mon, mailbox #(transaction) mbx_mon2sco);
            this.mbx_drv2mon = mbx_drv2mon;
            this.mbx_mon2sco = mbx_mon2sco;
            t = new();
        endfunction;
    
        task run();
            forever begin
                mbx_drv2mon.get(t);
                mbx_mon2sco.put(t.copy());
                $display ("[MON] Data sent to scoreboard");
            end
        endtask
    endclass
    
    class scoreboard;
        transaction t;
        mailbox #(transaction) mbx_mon2sco;
        function  new( mailbox #(transaction) mbx_mon2sco);
            this.mbx_mon2sco = mbx_mon2sco;
            t = new();
        endfunction;
    
        task run();
            int expected;
            forever begin
                mbx_mon2sco.get(t);
                expected = t.a * t.b;
                if (t.mul == expected)
                    $display("[SCO] ? PASS: a=%0d, b=%0d, DUT mul=%0d, expected=%0d", t.a, t.b, t.mul, expected);
                else
                    $display("[SCO] ? FAIL: a=%0d, b=%0d, DUT mul=%0d, expected=%0d", t.a, t.b, t.mul, expected);
            end
        endtask
    endclass
endpackage
