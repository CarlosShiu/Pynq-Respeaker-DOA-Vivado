`include    "global_header.vh"
module axis_bram_4_channel (
    input   wire                                s00_axis_aclk,
    input   wire                                s00_axis_aresetn,
    output  wire                                s00_axis_tready,
    input   wire    [`AXIS_TDATA_W - 1 : 0]     s00_axis_tdata,
    input   wire    [((`AXIS_TDATA_W/8)-1) : 0] s00_axis_tstrb,
    input   wire                                s00_axis_tlast,
    input   wire                                s00_axis_tvalid,
    
    output  wire                                all_close,
    
    // input   wire                                s01_axis_aclk,
    // input   wire                                s01_axis_aresetn,
    // output  wire                                s01_axis_tready,
    // input   wire    [`AXIS_TDATA_W - 1 : 0]     s01_axis_tdata,
    // input   wire    [((`AXIS_TDATA_W/8) - 1 : 0]s01_axis_tstrb,
    // input   wire                                s01_axis_tlast,
    // input   wire                                s01_axis_tvalid,
    
    // input   wire                                s02_axis_aclk,
    // input   wire                                s02_axis_aresetn,
    // output  wire                                s02_axis_tready,
    // input   wire    [`AXIS_TDATA_W - 1 : 0]     s02_axis_tdata,
    // input   wire    [((`AXIS_TDATA_W/8) - 1 : 0]s02_axis_tstrb,
    // input   wire                                s02_axis_tlast,
    // input   wire                                s02_axis_tvalid,
    
    // input   wire                                s03_axis_aclk,
    // input   wire                                s03_axis_aresetn,
    // output  wire                                s03_axis_tready,
    // input   wire    [`AXIS_TDATA_W - 1 : 0]     s03_axis_tdata,
    // input   wire    [((`AXIS_TDATA_W/8) - 1 : 0]s03_axis_tstrb,
    // input   wire                                s03_axis_tlast,
    // input   wire                                s03_axis_tvalid,
    
    input   wire                                m00_axis_aclk,
    input   wire                                m00_axis_aresetn,
    input   wire                                m00_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]     m00_axis_tdata,
    output  wire    [((`AXIS_TDATA_W/4)-1) : 0] m00_axis_tstrb,
    output  wire                                m00_axis_tlast,
    output  wire                                m00_axis_tvalid,
                                                
    input   wire                                m01_axis_aclk,
    input   wire                                m01_axis_aresetn,
    input   wire                                m01_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]     m01_axis_tdata,
    output  wire    [((`AXIS_TDATA_W/4)-1) : 0] m01_axis_tstrb,
    output  wire                                m01_axis_tlast,
    output  wire                                m01_axis_tvalid,
                                                
    input   wire                                m02_axis_aclk,
    input   wire                                m02_axis_aresetn,
    input   wire                                m02_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]     m02_axis_tdata,
    output  wire    [((`AXIS_TDATA_W/4)-1) : 0] m02_axis_tstrb,
    output  wire                                m02_axis_tlast,
    output  wire                                m02_axis_tvalid,
                                                
    input   wire                                m03_axis_aclk,
    input   wire                                m03_axis_aresetn,
    input   wire                                m03_axis_tready,
    output  wire    [`AXIS_TDATA_W*2 - 1 : 0]     m03_axis_tdata,
    output  wire    [((`AXIS_TDATA_W/4)-1) : 0] m03_axis_tstrb,
    output  wire                                m03_axis_tlast,
    output  wire                                m03_axis_tvalid
    );
    
    /*****Signal*****/
    //  global
    wire    aclk;
    wire    aresetn;
    wire    [`AXIS_TDATA_W - 1 : 0] data_in;
    reg     [5:0]                   data_cmp_0;
    reg     [5:0]                   data_cmp_1;
    reg     [5:0]                   data_cmp_2;
    wire    [5:0]                   data_cmp_2_abs;
    wire    [5:0]                   data_cmp_3;
    wire    [5:0]                   data_cmp_3_abs;
    wire    [5:0]                   data_cmp_dv_0;
    wire    [5:0]                   data_cmp_dv_1;
    wire    [5:0]                   data_cmp_dv_0_abs;
    wire    [5:0]                   data_cmp_dv_1_abs;
    reg     close;
    //  bram addr
    reg     [`AB4C_ADDR_W - 1 : 0]  addr_cnt_reg;
    reg     [`AB4C_ADDR_W - 1 : 0]  addr_cnt;
    reg     [3:0]                   addr_sh;
    //  bram
    wire    [`AXIS_TDATA_W - 1 : 0] raw_data_bram_0;
    wire    [`AXIS_TDATA_W - 1 : 0] raw_data_bram_1;
    wire    [`AXIS_TDATA_W - 1 : 0] raw_data_bram_2;
    wire    [`AXIS_TDATA_W - 1 : 0] raw_data_bram_3;
    //  output
    reg     [`AXIS_TDATA_W - 1 : 0] m0_temp_data;    
    reg     [`AXIS_TDATA_W - 1 : 0] m1_temp_data;    
    reg     [`AXIS_TDATA_W - 1 : 0] m2_temp_data;    
    
    
    /*****Logic*****/
    //  global
    assign  aclk = s00_axis_aclk;
    assign  aresetn = s00_axis_aresetn;
    assign  data_in = (!s00_axis_tdata[31]) ? {8'b0,s00_axis_tdata[31:8]} :
                      {8'b0,s00_axis_tdata[31],s00_axis_tdata[22:0]};
    always @ (posedge aclk) begin
        if (addr_sh[0] && s00_axis_tvalid)
            data_cmp_0 <= s00_axis_tdata[31:26];
        if (addr_sh[1] && s00_axis_tvalid)
            data_cmp_1 <= s00_axis_tdata[31:26];
        if (addr_sh[2] && s00_axis_tvalid)
            data_cmp_2 <= s00_axis_tdata[31:26];
    end
    assign  data_cmp_3 = s00_axis_tdata[31:26];
    assign  data_cmp_2_abs = (!data_cmp_2[5]) ? data_cmp_2 :
                             (1 + (~data_cmp_2[5:0]));
    assign  data_cmp_3_abs = (!data_cmp_3[5]) ? data_cmp_3 :
                             (1 + (~data_cmp_3[5:0]));
    assign  data_cmp_dv_0_abs = (!data_cmp_dv_0[5]) ? data_cmp_dv_0 :
                             (1 + (~data_cmp_dv_0[5:0]));
    assign  data_cmp_dv_1_abs = (!data_cmp_dv_1[5]) ? data_cmp_dv_1 :
                             (1 + (~data_cmp_dv_1[5:0]));
    assign  data_cmp_dv_0 = data_cmp_0 - data_cmp_2;
    assign  data_cmp_dv_1 = data_cmp_1 - s00_axis_tdata[31:26];
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == `RESET_ENABLE_) begin
            close <= `ENABLE;
        end
        else if ((addr_cnt == 0) && addr_sh[0] && s00_axis_tvalid) begin
            close <= `ENABLE;
        end
        else if ((addr_sh[3] && s00_axis_tvalid) && close) begin
            close <= (data_cmp_dv_0_abs <= (data_cmp_2_abs << 1)) &&
                     (data_cmp_dv_1_abs <= (data_cmp_3_abs << 1));
        end
    end
    //  output
    assign  all_close = close && (addr_cnt == 'd4095) && addr_sh[3];
    
    assign  s00_axis_tready = `ENABLE;
    
    assign  m00_axis_tdata = {32'b0,m0_temp_data};
    assign  m00_axis_tstrb = s00_axis_tstrb;
    assign  m00_axis_tlast = addr_sh[3] & s00_axis_tvalid & (addr_cnt == 'd4095);
    assign  m00_axis_tvalid = addr_sh[3] & s00_axis_tvalid;
    
    assign  m01_axis_tdata = {32'b0,m1_temp_data};
    assign  m01_axis_tstrb = s00_axis_tstrb;
    assign  m01_axis_tlast = addr_sh[3] & s00_axis_tvalid & (addr_cnt == 'd4095);
    assign  m01_axis_tvalid = addr_sh[3] & s00_axis_tvalid;
    
    assign  m02_axis_tdata = {32'b0,m2_temp_data};
    assign  m02_axis_tstrb = s00_axis_tstrb;
    assign  m02_axis_tlast = addr_sh[3] & s00_axis_tvalid & (addr_cnt == 'd4095);
    assign  m02_axis_tvalid = addr_sh[3] & s00_axis_tvalid;
    
    assign  m03_axis_tdata = {32'b0,s00_axis_tdata};
    assign  m03_axis_tstrb = s00_axis_tstrb;
    assign  m03_axis_tlast = addr_sh[3] & s00_axis_tvalid & (addr_cnt == 'd4095);
    assign  m03_axis_tvalid = addr_sh[3] & s00_axis_tvalid;
    always @ (posedge aclk) begin
        if (addr_sh[0] && s00_axis_tvalid) begin
            m0_temp_data <= s00_axis_tdata;
        end
        if (addr_sh[1] && s00_axis_tvalid) begin
            m1_temp_data <= s00_axis_tdata;
        end
        if (addr_sh[2] && s00_axis_tvalid) begin
            m2_temp_data <= s00_axis_tdata;
        end
    end
    //  bram addr
    always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == `RESET_ENABLE_) begin
            addr_sh <= 4'b1;
        end
        else if (s00_axis_tready && s00_axis_tvalid) begin
            addr_sh <= {addr_sh[2:0],addr_sh[3]};
        end
    end
    always @ (posedge aclk or negedge aresetn) begin
        addr_cnt_reg <= addr_cnt;
        if (aresetn == `RESET_ENABLE_) begin
            addr_cnt <= 'b0;
        end
        else if (s00_axis_tready && s00_axis_tvalid && addr_sh[3]) begin
            addr_cnt <= addr_cnt + 'b1;
        end
    end
    //  bram
    // raw_data raw_data_bram_0 (
        // .clka(aclk),    // input wire clka
        // .ena(ena),      // input wire ena
        // .wea(`ENABLE),      // input wire [0 : 0] wea
        // .addra(addr_cnt[0]),  // input wire [11 : 0] addra
        // .dina(data_in),    // input wire [31 : 0] dina
        // .douta(),  // output wire [31 : 0] douta
        // .clkb(aclk),    // input wire clkb
        // .enb(enb),      // input wire enb
        // .web(`DISABLE),      // input wire [0 : 0] web
        // .addrb(addrb),  // input wire [11 : 0] addrb
        // .dinb(32'b0),    // input wire [31 : 0] dinb
        // .doutb(raw_data_out_0)  // output wire [31 : 0] doutb
    // );    
    // raw_data raw_data_bram_1 (
        // .clka(aclk),    // input wire clka
        // .ena(ena),      // input wire ena
        // .wea(`ENABLE),      // input wire [0 : 0] wea
        // .addra(addr_cnt[1]),  // input wire [11 : 0] addra
        // .dina(data_in),    // input wire [31 : 0] dina
        // .douta(),  // output wire [31 : 0] douta
        // .clkb(aclk),    // input wire clkb
        // .enb(enb),      // input wire enb
        // .web(`DISABLE),      // input wire [0 : 0] web
        // .addrb(addrb),  // input wire [11 : 0] addrb
        // .dinb(32'b0),    // input wire [31 : 0] dinb
        // .doutb(raw_data_out_1)  // output wire [31 : 0] doutb
    // );    
    // raw_data raw_data_bram_2 (
        // .clka(aclk),    // input wire clka
        // .ena(ena),      // input wire ena
        // .wea(`ENABLE),      // input wire [0 : 0] wea
        // .addra(addr_cnt[2]),  // input wire [11 : 0] addra
        // .dina(data_in),    // input wire [31 : 0] dina
        // .douta(),  // output wire [31 : 0] douta
        // .clkb(aclk),    // input wire clkb
        // .enb(enb),      // input wire enb
        // .web(`DISABLE),      // input wire [0 : 0] web
        // .addrb(addrb),  // input wire [11 : 0] addrb
        // .dinb(32'b0),    // input wire [31 : 0] dinb
        // .doutb(raw_data_out_2)  // output wire [31 : 0] doutb
    // );    
    // raw_data raw_data_bram_3 (
        // .clka(aclk),    // input wire clka
        // .ena(ena),      // input wire ena
        // .wea(`ENABLE),      // input wire [0 : 0] wea
        // .addra(addr_cnt[3]),  // input wire [11 : 0] addra
        // .dina(data_in),    // input wire [31 : 0] dina
        // .douta(),  // output wire [31 : 0] douta
        // .clkb(aclk),    // input wire clkb
        // .enb(enb),      // input wire enb
        // .web(`DISABLE),      // input wire [0 : 0] web
        // .addrb(addrb),  // input wire [11 : 0] addrb
        // .dinb(32'b0),    // input wire [31 : 0] dinb
        // .doutb(raw_data_out_3)  // output wire [31 : 0] doutb
    // );
endmodule