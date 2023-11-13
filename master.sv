module apb_interface (
  input [0:0] clk,
  input [0:0] reset,
  input [31:0] inp_addr,
  input [31:0] inp_data,
  output reg [31:0] out_data
);
// добавить select, ready, enable

  // Регистры для хранения данных (можно добавить)
  bit [31:0] memory [0:128];

// переделать в таск, для упрощения работы
function apb_read;
input [31:0] addr;
reg [31:0] memory [0:128];
    begin
        apb_read = memory[addr];
    end
endfunction

task apb_write;
input [31:0] addr;
input [31:0] data;
    begin
        memory[addr] = data;
    end
endtask

always @(clk) begin
    apb_write(inp_addr, inp_data);
    out_data = apb_read(inp_addr);

end

endmodule
