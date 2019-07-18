`include    "global_header.vh"
module axis_fft_config (
    input   wire                                aclk,
    input   wire                                aresetn,
    
    input   wire                                m00_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m00_axis_tdata,
    output  wire                                m00_axis_tvalid,
    
    input   wire                                m01_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m01_axis_tdata,
    output  wire                                m01_axis_tvalid,
    
    input   wire                                m02_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m02_axis_tdata,
    output  wire                                m02_axis_tvalid,
    
    input   wire                                m03_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m03_axis_tdata,
    output  wire                                m03_axis_tvalid,
    
    input   wire                                m04_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m04_axis_tdata,
    output  wire                                m04_axis_tvalid,
    
    input   wire                                m05_axis_tready,
    output  wire    [`AXIS_TDATA_W/2 - 1 : 0]   m05_axis_tdata,
    output  wire                                m05_axis_tvalid
    
    );
    
    /*****Signal*****/
    reg     [`AXIS_TDATA_W/2 - 1 : 0]           rfft_config_data;
    reg     [`AXIS_TDATA_W/2 - 1 : 0]           irfft_config_data;
    reg                                         fst_config_valid;
    
    
    
    /*****Logic*****/
    assign  m00_axis_tdata = rfft_config_data;
    assign  m01_axis_tdata = rfft_config_data;
    assign  m02_axis_tdata = rfft_config_data;
    assign  m03_axis_tdata = rfft_config_data;
    assign  m04_axis_tdata = irfft_config_data;
    assign  m05_axis_tdata = irfft_config_data;
    assign  m00_axis_tvalid = fst_config_valid;
    assign  m01_axis_tvalid = fst_config_valid;
    assign  m02_axis_tvalid = fst_config_valid;
    assign  m03_axis_tvalid = fst_config_valid;
    assign  m04_axis_tvalid = fst_config_valid;
    assign  m05_axis_tvalid = fst_config_valid;
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == `RESET_ENABLE_) begin
            rfft_config_data <= 16'b0000_0000_0000_0001;
            irfft_config_data <= 16'b0000_0000_0000_0000;
        end
    end
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == `RESET_ENABLE_) begin
            fst_config_valid <= `ENABLE;
        end
        else if (fst_config_valid && m05_axis_tready && m04_axis_tready && 
                m03_axis_tready && m02_axis_tready && m01_axis_tready && 
                m00_axis_tready) begin
            fst_config_valid <= `DISABLE;
        end
    end
    
    
    
endmodule