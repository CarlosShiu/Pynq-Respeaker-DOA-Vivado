
`timescale 1 ns / 1 ps

	module respeaker_stream_v1_0 #
	(
		// Users to add parameters here
        parameter integer I2S_IN_WIDTH  = 3,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
        input wire [I2S_IN_WIDTH-1:0] I2S_i,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXIS
		input wire   									m00_axis_aclk,
		input wire   									m00_axis_aresetn,
		output wire  									m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] 		m00_axis_tdata,
//		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] 	m00_axis_tstrb,
//		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
	
	wire [2:0]		I2S_i;
//	wire 			M_AXIS_ACLK;
//	wire 			M_AXIS_ARESETN;
	wire 			M_AXIS_TVALID;
	wire [31:0]		M_AXIS_TDATA;
	wire 			M_AXIS_TREADY;
	
	
// Instantiation of Axi Bus Interface M00_AXIS
	respeaker_stream_v1_0_M00_AXIS # ( 
	    .I2S_IN_WIDTH(I2S_IN_WIDTH),
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) respeaker_stream_v1_0_M00_AXIS_inst (
		.I2S_i						(I2S_i),
		.M_AXIS_ACLK				(m00_axis_aclk),
		.M_AXIS_ARESETN				(m00_axis_aresetn),
		
		.M_AXIS_TVALID				(M_AXIS_TVALID),
		.M_AXIS_TDATA				(M_AXIS_TDATA),
//		.M_AXIS_TSTRB(m00_axis_tstrb),
//		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TSTRB				(),
		.M_AXIS_TLAST				(),
		.M_AXIS_TREADY				(M_AXIS_TREADY)
	);

	fifo_generator_0 fifo_axis_4096x4 (
		.wr_rst_busy				(),      					// output wire wr_rst_busy
		.rd_rst_busy				(),      					// output wire rd_rst_busy
		
		.s_aclk						(m00_axis_aclk),                	// input wire s_aclk
		.s_aresetn					(m00_axis_aresetn),          	// input wire s_aresetn
		
		.s_axis_tvalid				(M_AXIS_TVALID),  		// input wire s_axis_tvalid
		.s_axis_tready				(M_AXIS_TREADY),  		// output wire s_axis_tready
		.s_axis_tdata				(M_AXIS_TDATA),    		// input wire [63 : 0] s_axis_tdata
		
		.m_axis_tvalid				(m00_axis_tvalid),  		// output wire m_axis_tvalid
		.m_axis_tready				(m00_axis_tready),  		// input wire m_axis_tready
		.m_axis_tdata				(m00_axis_tdata)   		// output wire [63 : 0] m_axis_tdata
	);
	
	
	
	
	// Add user logic here

	// User logic ends

	endmodule
