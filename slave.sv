module slave (
    input [0:0] PCLK,
    input [0:0] PRESET,
    input [0:0] PSEL,
    input [0:0] PENABLE,
    input [0:0] PWRITE,
    input [31:0] PRWADDR,          // Master Out, Slave In
    input [31:0] PRWDATA,
    input [1:0] f,

    output reg [31:0] PRDATA1,     // Master In, Slave Out
    output reg [0:0] PREADY      // Slave PREADY
);

//reg [31:0] data_in;     // Входные данные от мастера
//reg [31:0] data_out;    // Выходные данные для слейва
reg [3:0] state;        // Состояние конечного автомата
reg [31:0] memory [0:127];
reg [2:0] c;

reg [31:0] a;
reg [31:0] b;
wire [3:0] aa;
wire [3:0] bb;
reg [0:0] s;
wire [3:0] ss;


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
    a = 0;
    b = 0;
    PREADY = 0;

    // memory[0] <= 32'h00000309;  // group number
    // memory[1] <= 32'h07122023;  // date
    // memory[2] <= 32'h444f4c5a;  // last_name
    // memory[3] <= 32'h44454e49;  // first_name

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
    
    //$display("in slave");

    if(PSEL == 1'b1 && PENABLE == 1'b1 && f == 2'b01) begin  
        // a[0] <= PRWDATA[0];
        // a[1] <= PRWDATA[1];
        // a[2] <= PRWDATA[2];
        // a[3] <= PRWDATA[3];
        a <= PRWDATA;
        PRDATA1 <= a;

        $display("a:");
        $display(a);
    end

    if(PSEL == 1'b1 && PENABLE == 1'b1 && f == 2'b10) begin  
        // b[0] <= PRWDATA[0];
        // b[1] <= PRWDATA[1];
        // b[2] <= PRWDATA[2];
        // b[3] <= PRWDATA[3];
        b <= PRWDATA;
        PRDATA1 <= b;

        $display("b:");
        $display(b);

    end

    if(PSEL == 1'b1 && PENABLE == 1'b1 && f == 2'b11) begin  

        // PRDATA1 = a | b; 
        // PRDATA1 = PRDATA1 + (a & b);
        // $display("%b",a);
        // $display("%b",b);
        // $display("%b",PRDATA1);
        PRDATA1 = 0;

        PRDATA1[0] = ((~a[0] & b[0]) | (a[0] & ~b[0]));
        $display("------------ start ------------");
        // $display("%b",a);
        // $display("%b",b);
        // $display("%b",PRDATA1);
        s = a[0] & b[0];

        for (integer i = 1;i < 32; i = i + 1) begin
            PRDATA1[i] = ((~((~a[i] & b[i]) | (a[i] & ~b[i])) & s) | (((~a[i] & b[i]) | (a[i] & ~b[i])) & ~s));
            s = (a[i] & b[i]) | (a[i] & s) | (b[i] & s);
        end
        // $display("%b",a);
        // $display("%b",b);
        // $display("%b",PRDATA1);

        // PRDATA1[2] = ((~((~a[2] & b[2]) | (a[2] & ~b[2])) & s) | (((~a[2] & b[2]) | (a[2] & ~b[2])) & ~s));
        // s =(a[2] & b[2]) | (a[2] & s) | (b[2] & s);

        // $display("%b",a);
        // $display("%b",b);
        // $display("%b",PRDATA1);

        // PRDATA1[3] = ((~((~a[3] & b[3]) | (a[3] & ~b[3])) & s) | (((~a[3] & b[3]) | (a[3] & ~b[3])) & ~s));
        // s = (a[3] & b[3]) | (a[3] & s) | (b[3] & s);

        $display("a: %b",a);
        $display("b: %b",b);
        $display("result: %b",PRDATA1);

        $display("a: %d",a);
        $display("b: %d",b);
        $display("result: %d",PRDATA1);



        //PRDATA1 = a + b;

        // $display("PRDATA1:");
        // $display(PRDATA1);
        $display("------------ end ------------");
    end

    if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b0) begin 
        //$display("if1");
        PREADY = 0; 
    end
        
    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0) begin  
        //$display("wriite in slave");
        //PRDATA1 <= memory[PRWADDR];
        PREADY = 1;
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b1) begin  
        //$display("if2");
        PREADY = 0; 
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1) begin  
        //$display("if3");
        PREADY = 1;
        //PRDATA1 <= PRWDATA;
        //memory[PRWADDR] <= PRWDATA;
    end

    else begin
        PREADY = 0;
        //$display("if4");
    end

    // $display("after slave -----------");
    // $display(PREADY);
    // $display(PENABLE);
    // $display(PWRITE);
    // $display("after slave ^^^^^^^^^^");
    end
end
endmodule
