`include    "global_header.vh"
`define     PIPE_TIME   26-2
module axis_msr_keep (
    input   wire                                s00_axis_aclk,
    input   wire                                s00_axis_aresetn,
    output  wire                                s00_axis_tready,
    input   wire    [`AXIS_TDATA_W*4 - 1 : 0]   s00_axis_tdata,
    input   wire                                s00_axis_tvalid,
    
    input   wire                                m00_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]   m00_axis_tdata,
    output  wire                                m00_axis_tvalid,
    output  wire                                m00_axis_tlast,
    
    input   wire                                m03_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]   m03_axis_tdata,
    output  wire                                m03_axis_tvalid,
    output  wire                                m03_axis_tlast,
    
    input   wire                                m01_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]   m01_axis_tdata,
    output  wire                                m01_axis_tvalid,
    output  wire                                m01_axis_tlast,
    
    input   wire                                m02_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]   m02_axis_tdata,
    output  wire                                m02_axis_tvalid,
    output  wire                                m02_axis_tlast
    );
    
    /*****Signal*****/
    //input pipeline
    wire    ipt_allin;
    reg     ipt_valid;
    reg     [`AXIS_TDATA_W*4 - 1 : 0]   ipt_keep_data;
    //output pipeline
    wire    opt_allin;
    reg     opt_valid;
    reg     [`AXIS_TDATA_W*4 - 1 : 0]   opt_keep_data;
//    wire     [`AXIS_TDATA_W*4 - 1 : 0]   opt_keep_data;
    //inner pipeline
    wire    [`PIPE_TIME - 1 : 0]        pipe_allin;
    reg     [`PIPE_TIME - 1 : 0]        pipe_valid;
    reg     [`AXIS_TDATA_W*4 - 1 : 0]   pipe_data   [`PIPE_TIME - 1 : 0];
    //msr
    wire    [95 : 0]                    msr_data;
    wire    [95 : 0]                    msr_o_data;
    wire                                msr_allin;
    wire                                msr_valid;
    //calcutation 
	wire [63:0]	mult_result_0;
	wire [63:0]	mult_result_1;
	wire [63:0] add_result;
	wire [24:0] sqrt_result;		//only use low 25 bit
	wire [63:0] calculate_result; 
	
    assign msr_allin = 1'b1;
	//coutner
	reg  [11:0]	data_counter;
	
	always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
			data_counter	<= 12'd0;
        end
		else if(opt_valid)
			data_counter 	<= data_counter + 1;
	end
	
    
    /*****Logic*****/
    //  output
    assign  s00_axis_tready = opt_allin && msr_allin;
    
//    assign  m00_axis_tdata = {msr_o_data[47:0],16'b0};
    assign  m00_axis_tdata = calculate_result;
//    assign  m00_axis_tvalid = msr_valid;
    assign  m00_axis_tvalid = opt_valid;
    assign  m00_axis_tlast  = ((data_counter == 12'd4095) && opt_valid);
	
//    assign  m03_axis_tdata = {msr_o_data[47:0],16'b0};
    assign  m03_axis_tdata = calculate_result;
//    assign  m03_axis_tvalid = msr_valid;
    assign  m03_axis_tvalid = opt_valid;
    assign  m03_axis_tlast  = ((data_counter == 12'd4095) && opt_valid);

    assign  m01_axis_tdata = opt_keep_data[63:0];
    assign  m01_axis_tvalid = opt_valid;
    assign  m01_axis_tlast  = ((data_counter == 12'd4095) && opt_valid);

    assign  m02_axis_tdata = opt_keep_data[127:64];
    assign  m02_axis_tvalid = opt_valid;
    assign  m02_axis_tlast  = ((data_counter == 12'd4095) && opt_valid);
    //inner pipeline
    genvar  pipe_time;
    generate 
        for (pipe_time = 0;pipe_time < `PIPE_TIME;pipe_time = pipe_time + 1) begin
            assign  pipe_allin[pipe_time] = (pipe_time == `PIPE_TIME - 1) ?
                (!pipe_valid[pipe_time] || opt_allin) :
                (!pipe_valid[pipe_time] || pipe_allin[pipe_time+1]);
            always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
                if (s00_axis_aresetn == `RESET_ENABLE_) begin
                    pipe_valid[pipe_time] <= `DISABLE;
                end
                else if (pipe_allin[pipe_time]) begin   
                    pipe_valid[pipe_time] <= (pipe_time == 0) ? ipt_valid :
                                             pipe_valid[pipe_time - 1];
                end
            end
            always @ (posedge s00_axis_aclk) begin
                if (pipe_allin[pipe_time] && ((pipe_time == 0) ? ipt_valid :
                                             pipe_valid[pipe_time - 1])) begin
                    pipe_data[pipe_time] <= (pipe_time == 0) ? ipt_keep_data :
                                            pipe_data[pipe_time - 1];
                end
            end
        end
    endgenerate
    
	
    //input pipeline
    assign  ipt_allin = !ipt_valid || pipe_allin[0];
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            ipt_valid <= `DISABLE;
        end
        else if (ipt_allin) begin
            ipt_valid <= s00_axis_tvalid;
        end
    end
    always @ (posedge s00_axis_aclk) begin
        if (ipt_allin && s00_axis_tvalid) begin
            ipt_keep_data <= s00_axis_tdata;
        end
    end
    //output pipeline
    assign  opt_allin = !opt_valid || (m00_axis_tready && m01_axis_tready 
                        && m02_axis_tready && m03_axis_tready);
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            opt_valid<= `DISABLE;
        end
        else if (ipt_allin) begin
            opt_valid <= pipe_valid[`PIPE_TIME - 1];
        end
    end
    always @ (posedge s00_axis_aclk) begin
        if (opt_allin && pipe_valid[`PIPE_TIME - 1]) begin
            opt_keep_data <= pipe_data[`PIPE_TIME - 1];
        end
    end
//	assign opt_keep_data = (opt_allin && opt_valid) ? pipe_data[`PIPE_TIME - 1] : 128'h0;

    //msr
    assign  msr_data = {s00_axis_tdata[127:80],s00_axis_tdata[63:16]};
//    axis_msr_48 axis_msr_48 (
//      .aclk(s00_axis_aclk),                                        // input wire aclk
//      .s_axis_cartesian_tvalid(s00_axis_tvalid),  // input wire s_axis_cartesian_tvalid
//      .s_axis_cartesian_tready(msr_allin),  // output wire s_axis_cartesian_tready
//      .s_axis_cartesian_tdata(msr_data),    // input wire [95 : 0] s_axis_cartesian_tdata
//      .m_axis_dout_tvalid(msr_valid),            // output wire m_axis_dout_tvalid
//      .m_axis_dout_tdata(msr_o_data)              // output wire [95 : 0] m_axis_dout_tdata
//    );



	mult_signed_32_32 mult_signed_32_32_0 (
		.CLK(s00_axis_aclk),  // input wire CLK
		.A(s00_axis_tdata[127:96]),      // input wire [31 : 0] A
		.B(s00_axis_tdata[127:96]),      // input wire [31 : 0] B
		.P(mult_result_0)      // output wire [63 : 0] P
	);
	
	mult_signed_32_32 mult_signed_32_32_1 (
		.CLK(s00_axis_aclk),  // input wire CLK
		.A(s00_axis_tdata[63:32]),      // input wire [31 : 0] A
		.B(s00_axis_tdata[63:32]),      // input wire [31 : 0] B
		.P(mult_result_1)      // output wire [63 : 0] P
	);
	
	add_signed_64_64 add_signed_64_64 (
		.A(mult_result_0),      // input wire [63 : 0] A
		.B(mult_result_1),      // input wire [63 : 0] B
		.CLK(s00_axis_aclk),  // input wire CLK
		.S(add_result)      // output wire [63 : 0] S
	);
	
	sqrt_48 sqrt_48 (
		.aclk(s00_axis_aclk),                                        // input wire aclk
		.s_axis_cartesian_tvalid(1), 						 // input wire s_axis_cartesian_tvalid
		.s_axis_cartesian_tdata(add_result[63:16]),   				 // input wire [47 : 0] s_axis_cartesian_tdata
		.m_axis_dout_tvalid(),            				// output wire m_axis_dout_tvalid
		.m_axis_dout_tdata(sqrt_result)              // output wire [31 : 0] m_axis_dout_tdata
	);
	
	assign calculate_result = {sqrt_result[23:0],8'b0,32'b0};
	
	
endmodule