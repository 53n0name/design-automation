module slave (
    input [0:0] PCLK,
    input [0:0] PRESET,
    input [0:0] PSEL,
    input [0:0] PENABLE,
    input [0:0] PWRITE,
    input [31:0] PRWADDR,          // Master Out, Slave In
    input [31:0] PRWDATA,
    output reg [31:0] PRDATA1,     // Master In, Slave Out
    output reg [0:0] PREADY      // Slave PREADY
);

//reg [31:0] data_in;     // Входные данные от мастера
//reg [31:0] data_out;    // Выходные данные для слейва
reg [3:0] state;        // Состояние конечного автомата
reg [31:0] memory [0:127];
reg [2:0] c;


// task apb_read;
// input [31:0] addr;
//     begin
//         out_data <= memory[addr];
//     end
// endtask

// task apb_write;
// input [31:0] addr;
// input [31:0] data;
//     begin
//         memory[addr] <= data;
//     end
// endtask
always @(PRESET) begin

if (PRESET == 1'b1) begin
    // Сброс в начальное состояние
    state <= 4'b0000;
    PRDATA1 <= 32'b00000000000000000000000000000000;
    //data_out <= 8'b00000000;
    //miso <= 32'b00000000000000000000000000000000;
    //PREADY <= 1'b0;

    PREADY = 0;

    memory[0] <= 32'h00000309;  // group number
    memory[1] <= 32'h07122023;  // date
    memory[2] <= 32'h444f4c5a;  // last_name
    memory[3] <= 32'h44454e49;  // first_name

end
end


// Логика конечного автомата
always @(posedge PCLK or posedge PRESET) begin

if (PRESET) begin
    // Сброс в начальное состояние
    state <= 4'b0000;
    PRDATA1 <= 32'b00000000000000000000000000000000;
    //data_out <= 8'b00000000;
    //miso <= 32'b00000000000000000000000000000000;
    //PREADY <= 1'b0;
end else begin    
    
    $display("in slave");

    if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b0) begin 
        $display("if1");
        PREADY = 0; 
    end
        
    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0) begin  
        $display("wriite in slave");
        PRDATA1 <= memory[PRWADDR];
        PREADY = 1;
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b1) begin  
        $display("if2");
        PREADY = 0; 
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1) begin  
        $display("if3");
        PREADY = 1;
        PRDATA1 <= PRWDATA;
        memory[PRWADDR] <= PRWDATA;
        c = c + 1;
    end

    else begin
        PREADY = 0;
        $display("if4");
    end

    // $display("after slave -----------");
    // $display(PREADY);
    // $display(PENABLE);
    // $display(PWRITE);
    // $display("after slave ^^^^^^^^^^");
    end
end
endmodule
