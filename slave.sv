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

reg [3:0] state;        // Состояние конечного автомата
reg [31:0] memory [0:127];
reg [2:0] c;
reg [1:0] flag;

reg [31:0] a;
reg [31:0] b;
wire [3:0] aa;
wire [3:0] bb;
reg [0:0] s;
wire [3:0] ss;

always @(PRESET) begin

if (PRESET == 1'b1) begin
    // Сброс в начальное состояние
    state <= 4'b0000;
    PRDATA1 <= 32'b00000000000000000000000000000000;

    a = 0;
    b = 0;
    flag = 0;
    PREADY = 0;

end
end

always @(posedge PCLK)begin 

    if (PSEL == 1'b1 && PENABLE == 1'b1) begin
    case (PRWADDR)
    32'b0000_0000_0000_0000_0000_0000_0000_0000: begin
        a <= PRWDATA;
        PRDATA1 <= a;
    end
    32'b0000_0000_0000_0000_0000_0000_0000_0100: begin
        b <= PRWDATA;
        PRDATA1 <= b;
    end 
    32'b0000_0000_0000_0000_0000_0000_0000_1000: begin
        flag <= PRWDATA[0];
    end 
    endcase
    end
end

always @(posedge PCLK) begin 
    if (PRESET)begin 
        PRDATA1 <= 0;
    end
    else begin 
        if (flag == 1'b1) begin
            PRDATA1 <= 0;
            PRDATA1 <= a + b;
        end
        else begin 
            PRDATA1 <= 0;
            if (a >= b)begin 
                PRDATA1 <= a - b;
            end
            else begin 
                PRDATA1 <= -(a - b);
                PRDATA1[31] <= 1;
                //PRDATA1 <= -PRDATA1;
            end

        end
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
    

    if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b0) begin 
        PREADY = 0; 
    end
        
    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b0) begin  
        PREADY = 1;
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b0 && PWRITE == 1'b1) begin  
        //$display("if2");
        PREADY = 0; 
    end

    else if(PSEL == 1'b1 && PENABLE == 1'b1 && PWRITE == 1'b1) begin  
        PREADY = 1;
    end

    else begin
        PREADY = 0;
        //$display("if4");
    end

    end
end
endmodule
