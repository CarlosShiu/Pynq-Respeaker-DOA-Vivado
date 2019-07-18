`include    "global_header.vh"
module axis_inverse_number (
    input   wire                                s00_axis_aclk,
    input   wire                                s00_axis_aresetn,
    output  wire                                s00_axis_tready,
    input   wire    [`AXIS_TDATA_W*2 - 1 : 0]    s00_axis_tdata,
    // input   wire    [((`AXIS_TDATA_W/8)-1) : 0] s00_axis_tstrb,
    input   wire                                s00_axis_tlast,
    input   wire                                s00_axis_tvalid,
    input   wire                                enable,
    
    input   wire                                all_close,
    
    input   wire                                m00_axis_aclk,
    input   wire                                m00_axis_aresetn,
    input   wire                                m00_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]   m00_axis_tdata,
    // output  wire    [((`AXIS_TDATA_W/8)-1) : 0] m00_axis_tstrb,
    output  wire                                m00_axis_tlast,
    output  wire                                m00_axis_tvalid
    );
    
    /*****Signal*****/
    reg     [`AB4C_ADDR_W - 1 : 0]              data_cnt;
    reg                                         all_close_reg;
    reg                                         all_close_pre_reg;
    
    reg     [(`AXIS_TDATA_W   - 1) : 0]         re_data_reg;
    reg     [(`AXIS_TDATA_W   - 1) : 0]         im_data_reg;
    reg                                         last_reg;
    // reg     [((`AXIS_TDATA_W/8)-1) : 0]         strb_reg;
    wire    [(`AXIS_TDATA_W   - 1) : 0]         inverse_im_data;
    wire    [(`AXIS_TDATA_W   - 1) : 0]         im_data;
    wire    [(`AXIS_TDATA_W   - 1) : 0]         re_data;
    //pipeline
    reg     valid;
    wire    allin;
    
    
    /*****Logic*****/
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            all_close_pre_reg <= `DISABLE;
        end
        else if (all_close) begin
            all_close_pre_reg <= `ENABLE;
        end
        else if ((data_cnt == 'd4095) && s00_axis_tready && s00_axis_tvalid) begin
            all_close_pre_reg <= `DISABLE;
        end
    end
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            all_close_reg <= `DISABLE;
        end
        else if ((data_cnt == 'd4095) && s00_axis_tready && s00_axis_tvalid) begin
            all_close_reg <= all_close_pre_reg;
        end
    end
    
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            data_cnt <= 'b0;
        end
        else if (s00_axis_tready && s00_axis_tvalid) begin
            data_cnt <= data_cnt + 1;
        end
    end
    assign  im_data = s00_axis_tdata[31:0];
    assign  re_data = s00_axis_tdata[63:32];
    assign  inverse_im_data = (!enable) ? im_data : (~im_data + 1);
    //output
    assign  m00_axis_tdata = {im_data_reg,re_data_reg};
    assign  m00_axis_tlast = last_reg;
    // assign  m00_axis_tstrb = strb_reg;
    assign  m00_axis_tvalid = valid;
    assign  s00_axis_tready = allin;
    //pipeline
    assign  allin = !valid || m00_axis_tready;
    always @ (posedge s00_axis_aclk or negedge s00_axis_aresetn) begin
        if (s00_axis_aresetn == `RESET_ENABLE_) begin
            valid <= `DISABLE;
        end
        else if (allin) begin
            valid <= s00_axis_tvalid;
        end
    end
    always @ (posedge s00_axis_aclk) begin
        if (allin && s00_axis_tvalid) begin
            // strb_reg <= s00_axis_tstrb;
            last_reg <= s00_axis_tlast;
            re_data_reg <= re_data & {`AXIS_TDATA_W{!all_close_reg}};
            im_data_reg <= inverse_im_data & {`AXIS_TDATA_W{!all_close_reg}};
        end
    end
    
    
endmodule