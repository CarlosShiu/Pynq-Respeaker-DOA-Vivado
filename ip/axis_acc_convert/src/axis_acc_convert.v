`include    "global_header.vh"
module axis_acc_convert (
    input   wire                                axis_aclk,
    input   wire                                axis_aresetn,
    input   wire    [32*4 - 1 : 0]              s00_axis_tdata,
    input   wire                                s00_axis_tvalid,
    output  wire                                s00_axis_tready,
    
    input   wire    [32*4 - 1 : 0]              s01_axis_tdata,
    input   wire                                s01_axis_tvalid,
    output  wire                                s01_axis_tready,
    
    input   wire                                m00_axis_tready,
    output  wire    [32*2 - 1 : 0]              m00_axis_tdata,
    output  wire                                m00_axis_tlast,
    output  wire                                m00_axis_tvalid
    );
    
    /*****Signal*****/
    wire    [32*2 - 1 : 0]   re_quo_data;
    wire    [32*2 - 1 : 0]   re_fra_data;
    wire    [32*2 - 1 : 0]   im_quo_data;
    wire    [32*2 - 1 : 0]   im_fra_data;
    wire    [32- 1 : 0]     im_o_data;
    wire    [32- 1 : 0]     re_o_data;
    reg     [12 -1 : 0]     cnt;
    
    
    
    /*****Logic*****/
    assign  re_quo_data = s00_axis_tdata[127:64];
    assign  re_fra_data = s00_axis_tdata[63:0];
    assign  im_quo_data = s01_axis_tdata[127:64];
    assign  im_fra_data = s01_axis_tdata[63:0];
    
    assign  im_o_data = {im_quo_data[63],im_quo_data[0],im_fra_data[63:34]};
    assign  re_o_data = {re_quo_data[63],re_quo_data[0],re_fra_data[63:34]};
    
    // assign  m00_axis_tdata = {im_o_data,re_o_data};
    assign  m00_axis_tdata = {im_fra_data,re_fra_data};
    assign  m00_axis_tvalid = s00_axis_tvalid && s01_axis_tvalid;
    assign  m00_axis_tlast = (cnt == 'd4095) && m00_axis_tvalid;
    
    assign  s00_axis_tready = m00_axis_tready;
    assign  s01_axis_tready = m00_axis_tready;
    
    always @ (posedge axis_aclk or negedge axis_aresetn) begin
        if (axis_aresetn == 0) begin
            cnt <= 0;
        end
        else if (m00_axis_tvalid && m00_axis_tready) begin
            cnt <= cnt + 1;
        end
    end
endmodule