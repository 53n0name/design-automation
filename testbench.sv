`include "master.sv"
`include "slave.sv"

module testbench;

reg [0:0] PCLK;
reg [0:0] PRESET;

reg [0:0] PSEL;
reg [0:0] transfer;
reg [0:0] r;
reg [0:0] PWRITE;

reg [31:0] PADDR;
reg [31:0] PDATA;

wire [0:0] PENABLE;
wire [31:0] PRWDATA;
wire [31:0] PRWADDR;

wire [31:0] PRDATA1;
wire [0:0] PREADY;

reg [3:0] Sum_reg;     // Регистр для хранения промежуточной BCD суммы
reg [0:0] Cout_reg;    // Регистр для хранения промежуточного переноса

reg [3:0] A_reg;
reg [3:0] B_reg;
reg [0:0] Cin;
reg [1:0] f;

reg [7:0] out;
reg [0:0] carry;

master m (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PSEL(PSEL),
    .PREADY(PREADY),
    .transfer(transfer),
    .PWRITE(PWRITE),      
    .PADDR(PADDR),
    .PDATA(PDATA),

    .PENABLE(PENABLE),
    .PRWDATA(PRWDATA),
    .PRWADDR(PRWADDR)
);

slave s (
    .PCLK(PCLK),
    .PRESET(PRESET),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .f(f),

    .PRWDATA(PRWDATA),  // master out, slave in data
    .PRWADDR(PRWADDR),  // master out, slava in addr

    .PRDATA1(PRDATA1),        // slave out data
    .PREADY(PREADY)        
);


// сначала делаем чтение в мастере,
// потом делаем передачу в слейв, где мы читаем память и изменяем
// в соответствии с заданием


initial begin

    $display("start");
    $dumpfile("testbench.vcd");
    $dumpvars(0,testbench);
    PADDR = 32'b00000000000000000000000000000000;
    PDATA = 32'h00000309;

    PWRITE = 1'b1;
    
    PCLK = 1'b0;
    PRESET = 0;
    PSEL = 0;
    transfer = 1'b1;

    PRESET = 1;
    #10;

    PRESET = 0;
    PSEL = 1;
    #40;

    PSEL = 0;
    #20;

    f = 2'b01;
    PADDR = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
    PDATA = 32'b0110_0000_0000_0000_0000_0000_0000_0001;
    PSEL = 1;
    #40;
    PSEL = 0;
    #20;
    $display("-------------------f01");
    $display(PRDATA1);

    f = 2'b10;
    PADDR = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
    PDATA = 32'b0001_0000_0000_0000_0000_0000_0000_0101;
    PSEL = 1;
    #40;
    PSEL = 0;
    #20;
    $display("-------------------f10");
    $display(PRDATA1);

    f = 2'b11;
    PADDR = 32'b0000_0000_0000_0000_0000_0000_0000_1100;
    PDATA = 32'b0000_0000_0000_0000_0000_0000_0000_1100;
    PSEL = 1;
    #40;
    PSEL = 0;
    #20;
    $display("-------------------start");

    $display(PRDATA1);

    $display("-------------------end");
    $finish;
end

always begin
    #5 PCLK = ~PCLK;
end

endmodule