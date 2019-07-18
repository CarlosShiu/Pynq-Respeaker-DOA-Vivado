`include    "global_header.vh"
module axis_compare (
    input   wire                                axis_aclk,
    input   wire                                axis_aresetn,
    input   wire    [`AXIS_TDATA_W*2 - 1 : 0]   s00_axis_tdata,
    input   wire                                s00_axis_tvalid,
    
    input   wire    [`AXIS_TDATA_W*2 - 1 : 0]   s01_axis_tdata,
    input   wire                                s01_axis_tvalid,
    
    output  wire                                compare_irq,
    
    input   wire  s00_axi_aclk,
	input   wire  s00_axi_aresetn,
	input   wire [32-1 : 0] s00_axi_awaddr,
	input   wire [2 : 0] s00_axi_awprot,
	input   wire  s00_axi_awvalid,
	output  wire  s00_axi_awready,
	input   wire [32-1 : 0] s00_axi_wdata,
	input   wire [(32/8)-1 : 0] s00_axi_wstrb,
	input   wire  s00_axi_wvalid,
	output  wire  s00_axi_wready,
	output  wire [1 : 0] s00_axi_bresp,
	output  wire  s00_axi_bvalid,
	input   wire  s00_axi_bready,
	input   wire [32-1 : 0] s00_axi_araddr,
	input   wire [2 : 0] s00_axi_arprot,
	input   wire  s00_axi_arvalid,
	output  wire  s00_axi_arready,
	output  wire [32-1 : 0] s00_axi_rdata,
	output  wire [1 : 0] s00_axi_rresp,
	output  wire  s00_axi_rvalid,
	input   wire  s00_axi_rready
    );
    
    /*****Signal*****/
    wire    [`AXIS_TDATA_W - 1 : 0]             re_data_0;
    wire    [`AXIS_TDATA_W - 1 : 0]             re_data_1;
    wire    [`AXIS_TDATA_W - 1 : 0]             im_data_0;
    wire    [`AXIS_TDATA_W - 1 : 0]             im_data_1;
    
    reg     [`AB4C_ADDR_W - 1 : 0]              data_cnt_0;
    reg     [`AB4C_ADDR_W - 1 : 0]              data_cnt_0_reg;
    reg     [`AB4C_ADDR_W - 1 : 0]              data_cnt_1;
    wire                                        compare_enable;
    
    reg     [`AXIS_TDATA_W - 1 : 0]             max_data_0;
    reg     [2:0]                               max_addr_0;
    wire                                        ipt_is_max_0;
    reg     [`AXIS_TDATA_W - 1 : 0]             max_data_1;
    reg     [2:0]                               max_addr_1;
    wire                                        ipt_is_max_1;
    
    reg     [`AXIL_DATA_W - 1 : 0]              data2axil;
    
    reg                                         end_once_compare;
    
    reg                                         zero_dect;
    
    
    /*****Logic*****/
    assign  compare_irq = end_once_compare;
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            end_once_compare <= `DISABLE;
        end
        else if (s00_axi_arvalid && s00_axi_arready) begin
            end_once_compare <= `DISABLE;
        end
        else if (!end_once_compare) begin   
            end_once_compare <= data_cnt_0_reg == 'd4095;
        end
    end
    
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            zero_dect <= `ENABLE;
        end
        else if ((data_cnt_0 == 0) && s00_axis_tvalid) begin
            zero_dect <= `ENABLE;
        end
        else if (s00_axis_tvalid && zero_dect) begin
            zero_dect <= (re_data_0 == 0) && (re_data_1 == 0);
        end
    end
    
    assign  re_data_0 = (!s00_axis_tdata[31]) ? s00_axis_tdata[31:0]
                        : ((~s00_axis_tdata[31:0]) + 1);
    assign  re_data_1 = (!s01_axis_tdata[31]) ? s01_axis_tdata[31:0]
                        : ((~s01_axis_tdata[31:0]) + 1);
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            data_cnt_0 <= 'b0;
        end 
        else if (s00_axis_tvalid) begin
            data_cnt_0 <= data_cnt_0 + 1;
        end
    end
    always @ (posedge axis_aclk) begin
        data_cnt_0_reg <= data_cnt_0;
    end
    assign  compare_enable = (data_cnt_0 == 'd4093) ||
                             (data_cnt_0 == 'd4094) ||
                             (data_cnt_0 == 'd4095) ||
                             (data_cnt_0 == 'd0) ||
                             (data_cnt_0 == 'd1) ||
                             (data_cnt_0 == 'd2) ||
                             (data_cnt_0 == 'd3);
                             
    assign  ipt_is_max_0 = re_data_0 > max_data_0;
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            max_data_0 <= 'b0;
        end
        else if ((data_cnt_0_reg == 'd4095)) begin
            max_data_0 <= 'b0;
        end
        else if (ipt_is_max_0 && compare_enable) begin
            max_data_0 <= re_data_0;
        end
    end
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            max_addr_0 <= 'b0;
        end
        
        else if ((data_cnt_0_reg == 'd4095)) begin
            max_addr_0 <= 'b0;
        end
        else if ((data_cnt_0 == 'd4095) && zero_dect) begin
            max_addr_0 <= 'b0;
        end
        else if (ipt_is_max_0 && compare_enable) begin
            case (data_cnt_0) 
                'd4093 : max_addr_0 <= 'd1;
                'd4094 : max_addr_0 <= 'd2;
                'd4095 : max_addr_0 <= 'd3;
                'd0    : max_addr_0 <= 'd4;
                'd1    : max_addr_0 <= 'd5;
                'd2    : max_addr_0 <= 'd6;
                'd3    : max_addr_0 <= 'd7;
            endcase
        end
    end                         
    assign  ipt_is_max_1 = re_data_1 > max_data_1;
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            max_data_1 <= 'b0;
        end
        else if ((data_cnt_0_reg == 'd4095)) begin
            max_data_1 <= 'b0;
        end
        else if (ipt_is_max_1 && compare_enable) begin
            max_data_1 <= re_data_1;
        end
    end
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            max_addr_1 <= 'b0;
        end
        else if ((data_cnt_0_reg == 'd4095)) begin
            max_addr_1 <= 'b0;
        end
        else if ((data_cnt_0 == 'd4095) && zero_dect) begin
            max_addr_1 <= 'b0;
        end
        else if (ipt_is_max_1 && compare_enable) begin
            case (data_cnt_0) 
                'd4093 : max_addr_1 <= 'd1;
                'd4094 : max_addr_1 <= 'd2;
                'd4095 : max_addr_1 <= 'd3;
                'd0    : max_addr_1 <= 'd4;
                'd1    : max_addr_1 <= 'd5;
                'd2    : max_addr_1 <= 'd6;
                'd3    : max_addr_1 <= 'd7;
            endcase
        end
    end
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == `RESET_ENABLE_) begin
            data2axil <= 'b0;
        end
        else if (data_cnt_0_reg == 'd4095) begin
            data2axil <= {26'b0,max_addr_1,max_addr_0};
        end
    end
    axi_lite_intf # ( 
	) axi_lite_intf (
        .compare_result(data2axil),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr[3:0]),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr[3:0]),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
    
endmodule