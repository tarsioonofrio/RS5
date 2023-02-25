/*!\file testbench.sv
 * PUCRS-RV VERSION - 1.0 - Public Release
 *
 * Distribution:  December 2021
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * Testbench for pucrs-rv simulation.
 *
 * \detailed
 * Testbench for pucrs-rv simulation.
 */

`timescale 1ns/1ps

import my_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////// CPU TESTBENCH IMPLEMENTATION //////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Testbench_With_BRAMs ();

logic         clk=1, rstCPU;
logic [7:0]   gpioa_out, gpioa_addr;
logic [31:0]  IRQ;
byte          char;

assign IRQ = '0;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// RESET CPU ////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    initial begin
        rstCPU = 0;
        #1000 rstCPU = 1;
/*
        #5000
        IRQ[11] <= 1;
        #100
        IRQ[11] <= 0;
        #30
        IRQ[3] <= 1;
        #70
        IRQ[3] <= 0;
        #30
        IRQ[7] <= 1;
        #70
        IRQ[7] <= 0;
*/    
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// Clock generator //////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always begin
        #5.0 clk = 0;
        #5.0 clk = 1;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// CPU INSTANTIATION ////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    PUC_RS5_With_BRAMs dut (
        .clk(clk), 
        .reset(rstCPU), 
        .gpioa_out(gpioa_out),
        .gpioa_addr(gpioa_addr)
//        .IRQ(IRQ)
    );

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// Memory Mapped regs ///////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        ///////////////////////////////////// OUTPUT REG ///////////////////////////////////
        if(gpioa_addr == 8'h84 || gpioa_addr == 8'h81) begin
            char <= gpioa_out;
            $write("%c",char);
        end
        ///////////////////////////////////// END REG //////////////////////////////////////
        else if (gpioa_addr==8'h80) begin
            $display("\n#%0t END OF SIMULATION\n",$time);
            $finish;
        end
    end


endmodule
