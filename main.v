module VGA(
    input  wire       PCLK,
    input  wire [7:0] PRAM,
    output wire       HSYNC,
    output wire       VSYNC,
    output wire       HBLANK,
    output wire       VBLANK,
    output wire [7:0] RGB332
);
    /* horizontal timing parameters */
    localparam H_SYNC  = 95;
    localparam H_ENTR  = 142;
    localparam H_BACK  = 143;
    localparam H_EXIT  = 782;
    localparam H_DISP  = 783;
    localparam H_FRONT = 799;

    /* vertical timing parameters */
    localparam V_SYNC  = 1;
    localparam V_BACK  = 34;
    localparam V_DISP  = 514;
    localparam V_FRONT = 524;

    /* VGA timing counters */
    reg [9:0] hcnt = 0;
    reg [9:0] vcnt = 0;

    /* blanking signals */
    assign HBLANK = hcnt < H_BACK || hcnt >= H_DISP;
    assign VBLANK = vcnt < V_BACK || vcnt >= V_DISP;

    /* VGA sync & color signals */
    assign HSYNC       = hcnt > H_SYNC;
    assign VSYNC       = vcnt > V_SYNC;
    assign RGB332[7:0] = HBLANK || VBLANK ? 0 : PRAM[7:0];

    /* horizontal timing */
    always @(posedge PCLK) begin
        hcnt <= hcnt == H_FRONT ? 0 : hcnt + 1;
    end

    /* vertical timing */
    always @(posedge PCLK) begin
        if (hcnt == H_FRONT) begin
            vcnt <= vcnt == V_FRONT ? 0 : vcnt + 1;
        end
    end
endmodule

module main(
    input  wire clk,
    output wire P45,
    output wire P43,
    output wire P38,
    output wire P36,
    output wire P32,
    output wire P28,
    output wire P26,
    output wire P23,
    output wire P46,
    output wire P44,
    output wire P42,
    output wire P37,
    output wire P34,
    output wire P31,
    output wire LED_R,
    output wire LED_G
);
    wire pclk;
    wire locked;

    /* pixel clock @ 25.125MHz */
    PLL pll(
        .clock_in  (clk),
        .clock_out (pclk),
        .locked    (locked)
    );

    /* sync & blanking signals */
    wire hsync;
    wire vsync;
    wire hblank;
    wire vblank;

    /* assign the sync signals */
    assign P34 = hsync;
    assign P31 = vsync;

    /* lower bits of the RGB signals */
    assign P32 = P26;
    assign P44 = P37;
    assign P45 = P38;
    assign P46 = P42;

    reg frame = 1;
    reg [9:0] xpos = 0;
    reg [9:0] cols = 1;
    reg [7:0] pixel = 0;
    reg [23:0] blink = 0;
    assign LED_R = frame;
    assign LED_G = blink[23];

    VGA vga(
        .PCLK   (pclk),
        .PRAM   (pixel),
        .HSYNC  (hsync),
        .VSYNC  (vsync),
        .HBLANK (hblank),
        .VBLANK (vblank),
        .RGB332 ({P36, P38, P43, P23, P26, P28, P37, P42})
    );

    always @(posedge pclk) begin
        if (~hsync && ~vsync) begin
            xpos  <= xpos == 639 ? 0 : xpos + 1;
            frame <= ~frame;
        end
        if (~hblank && ~vblank) begin
            blink <= blink + 1;
            if (cols == 0 || cols == 639) begin
                pixel <= 8'b11111111;
            end else begin
                pixel <= 0;
            end
            if (cols != 639) begin
                cols <= cols + 1;
            end else begin
                cols <= 0;
            end
        end
    end
endmodule
