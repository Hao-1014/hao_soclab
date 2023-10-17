module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,    
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready, 
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);
begin
    //////////////////adress parameter////////////////////
    parameter 
    ap_ctrl_addr = 12'h00,
    data_length_addr = 12'h10,
    tap_addr = 12'h20; 
    /////////////////////////////////////////////////////
    reg AWREADY,WREADY;
    reg ARREADY,RVALID;
    //////////////////AXI_WRITE/////////////////////////
    //awready// 
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n) 
            AWREADY <= 1'b0;
        else begin
            if(awvalid) AWREADY <= 1'b1;
            else AWREADY <= 1'b0;
        end  
    end
    assign awready = AWREADY;
    
    //wready//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)
            WREADY <= 1'b0;
        else begin
            if(wvalid) WREADY <= 1'b1;
            else WREADY <= 1'b0;
        end
    end
    assign wready = AWREADY; 
    //////////////////////////////////////////////////////////////////
    ///////////////////////AXI_READ///////////////////////////////////
    //arready//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)
            ARREADY <= 1'b0;
        else begin
            if(arvalid & !ARREADY) ARREADY <= 1'b1;
            else ARREADY <= 1'b0;
        end
    end
    assign arready = ARREADY;     
    
    //rvalid//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)
            RVALID <= 1'b0;
        else begin
            if(arvalid) RVALID <= 1'b1;  //not sure if need to use continuous  (depends on rready)
            else RVALID <= 1'b0;
        end
    end
    assign rvalid = RVALID;    
    ////////////////////////////////////////////////////
    ///////////////////tap_ram//////////////////////////    
    reg [3:0] TAP_WE;
    reg TAP_EN;
    reg signed [(pDATA_WIDTH-1):0] TAP_DI;
    reg [(pADDR_WIDTH-1):0] TAP_A;
    
    //tap_WE//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n) TAP_WE <= 4'b0;
        else begin
            if(awaddr != 12'h00 && awaddr != 12'h10 && awvalid )
                TAP_WE <= 4'b1111;
            else 
                TAP_WE <= 4'b0;    
        end
    end
    assign tap_WE = TAP_WE;
    
    //tap_EN//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)
            TAP_EN <= 1'b0;
        else 
            TAP_EN <= 1'b1;
    end
    assign tap_EN = TAP_EN;
    
    //tap_A//
    always @(awaddr or araddr or negedge axis_rst_n)begin
        if(!axis_rst_n) TAP_A <= 12'b0;
        else begin 
            if(awaddr != 12'h00 && awaddr != 12'h10)
                TAP_A <= awaddr;
        end
    end 
    assign tap_A = TAP_A;
    
    //tap_Di// 
    always @(wdata)begin
        if(wvalid && awaddr!=12'h00 && awaddr!=12'h10) TAP_DI <= wdata;
        //else TAP_DI <= 32'b0;
    end
    assign tap_Di = TAP_DI;
    ////////////////////////////////////////////////
    
    //////////////DATA_RAM//////////////////////////
    reg [3:0] DATA_WE;
    reg DATA_EN;
    reg SS_TREADY;
    //data_WE//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n) DATA_WE <= 4'd0;
        else begin
            if(SS_TREADY) DATA_WE <= 4'd1;  //nor sure of the condition, shuld be checked later
            else DATA_WE <= 4'd0;
        end
    end
    assign data_WE = DATA_WE;   
    
    //data_EN//
    always @(posedge axis_clk or negedge axis_rst_n)begin
        if(!axis_rst_n)
            DATA_EN <= 1'b0;
        else 
            DATA_EN <= 1'b1;
    end
    assign data_EN = DATA_EN;
    
    
    
    
   /////////////////////////////////////////////////////////// 
end


endmodule