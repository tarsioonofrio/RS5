/*!\file testbench.sv
 * RS5 VERSION - 1.1.0 - Pipeline Simplified and Core Renamed
 *
 * Distribution:  July 2023
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * Testbench for RS5 simulation.
 *
 * \detailed
 * Testbench for RS5 simulation.
 */

`timescale 1ns/1ps

import RS5_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CPU TESTBENCH IMPLEMENTATION
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Testbench_FPGA_Platform ();

    parameter i_cnt = 1;

    logic           clk=1, rstCPU;
    logic [7:0]     gpioa_out, gpioa_addr;
    byte            char;
    logic           BTND;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESET CPU 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    initial begin
        rstCPU = 0;
        #1000 
        rstCPU = 1; 
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clock generator
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always begin
        #5.0 clk = 0;
        #5.0 clk = 1;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CPU INSTANTIATION 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    RS5_FPGA_Platform dut (
        .clk        (clk), 
        .reset      (rstCPU), 
        .gpioa_out  (gpioa_out),
        .gpioa_addr (gpioa_addr),
        .BTND       (BTND)
    );

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Memory Mapped regs
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always @(posedge clk) begin
        ///////////////////////////////////// OUTPUT REG ///////////////////////////////////
        if (gpioa_addr == 8'h84 || gpioa_addr == 8'h81) begin
            char <= gpioa_out;
            $write("%c",char);
        end
        ///////////////////////////////////// END REG //////////////////////////////////////
        else if (gpioa_addr==8'h80) begin
            $display("\n#%0t END OF SIMULATION\n",$time);
            $finish;
        end
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interrupt Emulation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    initial begin
        BTND  = 0;
        #3000
        BTND  = 1; 
    end


endmodule
