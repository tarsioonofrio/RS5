/*!\file ram.sv
 * RS5 VERSION - 1.0 - Public Release
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
 * RAM implementation for RS5 simulation.
 *
 * \detailed
 * RAM implementation for RS5 simulation.
 */

//////////////////////////////////////////////////////////////////////////////
// RAM MEMORY
//////////////////////////////////////////////////////////////////////////////

module RAM_mem 
    import RS5_pkg::*;
(
    input  logic clk,

    input  logic        enA_i,
    input  logic [ 3:0] weA_i,
    input  logic [15:0] addrA_i,
    input  logic [31:0] dataA_i,
    output logic [31:0] dataA_o,

    input  logic        enB_i,
    input  logic [ 3:0] weB_i,
    input  logic [15:0] addrB_i,
    input  logic [31:0] dataB_i,
    output logic [31:0] dataB_o
);

    reg [7:0] RAM [0:65535];
    int fd, r;

`ifdef DEBUG
    int fd_a, fd_r, fd_w;
`endif

    initial begin
        fd = $fopen ("../app/berkeley_suite/test.bin", "r");

        r = $fread(RAM, fd);
        $display("read %d elements \n", r);

    `ifdef DEBUG
        fd_a = $fopen ("./debug/PortA.txt", "w");
        fd_b = $fopen ("./debug/PortB.txt", "w");
        fd_w = $fopen ("./debug/writes.txt", "w");
    `endif
    end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////// A PORT /////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk) begin
        if (enA_i == 1'b1) begin
            ///////////////////////////// Writes  ///////////////////////////////////////////
            if (weA_i != '0) begin
                if (weA_i[3] == 1'b1) begin                                 // Store Word(4 bytes)
                    RAM[addrA_i+3] <= dataA_i[31:24];
                end 
                if (weA_i[2] == 1'b1) begin                                 // Store Word(4 bytes)
                    RAM[addrA_i+2] <= dataA_i[23:16];
                end
                if (weA_i[1] == 1'b1) begin                                 // Store Half(2 bytes)
                    RAM[addrA_i+1] <= dataA_i[15:8];
                end
                if (weA_i[0] == 1'b1) begin                                 // Store Byte(1 byte)
                    RAM[addrA_i]   <= dataA_i[7:0];
                end

            `ifdef DEBUG
                $fwrite(fd_w,"[%0d] ", $time);
                if (weA_i[3] == 1'b1) $fwrite(fd_w,"%h ", dataA_i[31:24]); else $fwrite(fd_w,"-- ");
                if (weA_i[2] == 1'b1) $fwrite(fd_w,"%h ", dataA_i[23:16]); else $fwrite(fd_w,"-- ");
                if (weA_i[1] == 1'b1) $fwrite(fd_w,"%h ", dataA_i[15:8 ]); else $fwrite(fd_w,"-- ");
                if (weA_i[0] == 1'b1) $fwrite(fd_w,"%h ", dataA_i[ 7:0 ]); else $fwrite(fd_w,"-- ");
                $fwrite(fd_w," --> 0x%4h\n", addrA_i);
            `endif
            end 
            // Reads 
            else begin
                dataA_o[31:24] <= RAM[addrA_i+3];
                dataA_o[23:16] <= RAM[addrA_i+2];
                dataA_o[15:8]  <= RAM[addrA_i+1];
                dataA_o[7:0]   <= RAM[addrA_i];

            `ifdef DEBUG
                if (addrA_i != '0) begin
                    $fwrite(fd_a,"[%0d] %h %h %h %h <-- 0x%4h\n", 
                        $time, RAM[addrA_i+3], RAM[addrA_i+2], RAM[addrA_i+1], RAM[addrA_i], addrA_i);
                end
            `endif
            end
        end 
        else begin
            dataA_o <= '0;
        end
    end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////// B PORT /////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk) begin
        if (enB_i == 1'b1) begin
            ///////////////////////////// Writes  ///////////////////////////////////////////
            if (weB_i != '0) begin
                if (weB_i[3] == 1'b1) begin                                 // Store Word(4 bytes)
                    RAM[addrB_i+3] <= dataB_i[31:24];
                end 
                if (weB_i[2] == 1'b1) begin                                 // Store Word(4 bytes)
                    RAM[addrB_i+2] <= dataB_i[23:16];
                end
                if (weB_i[1] == 1'b1) begin                                 // Store Half(2 bytes)
                    RAM[addrB_i+1] <= dataB_i[15:8];
                end
                if (weB_i[0] == 1'b1) begin                                 // Store Byte(1 byte)
                    RAM[addrB_i]   <= dataB_i[7:0];
                end

            `ifdef DEBUG
                $fwrite(fd_w,"[%0d] ", $time);
                if (weB_i[3] == 1'b1) $fwrite(fd_w,"%h ", dataB_i[31:24]); else $fwrite(fd_w,"-- ");
                if (weB_i[2] == 1'b1) $fwrite(fd_w,"%h ", dataB_i[23:16]); else $fwrite(fd_w,"-- ");
                if (weB_i[1] == 1'b1) $fwrite(fd_w,"%h ", dataB_i[15:8]);  else $fwrite(fd_w,"-- ");
                if (weB_i[0] == 1'b1) $fwrite(fd_w,"%h ", dataB_i[7:0]);   else $fwrite(fd_w,"-- ");
                $fwrite(fd_w," --> 0x%4h\n", addrB_i);
            `endif
            end 
            // Reads 
            else begin
                dataB_o[31:24] <= RAM[addrB_i+3];
                dataB_o[23:16] <= RAM[addrB_i+2];
                dataB_o[15:8]  <= RAM[addrB_i+1];
                dataB_o[7:0]   <= RAM[addrB_i];

            `ifdef DEBUG
                if (addrB_i != '0) begin
                    $fwrite(fd_b,"[%0d] %h %h %h %h <-- 0x%4h\n", 
                        $time, RAM[addrB_i+3], RAM[addrB_i+2], RAM[addrB_i+1], RAM[addrB_i], addrB_i);
                end
            `endif
            end
        end 
        else begin
            dataB_o <= '0;
        end
    end

endmodule
