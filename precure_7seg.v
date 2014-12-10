
`default_nettype none
module precure_7seg (
    input  wire clk,
    input  wire btnC,
    output wire [6:0] seg,
    output wire dp,
    output wire [3:0] an
);

    reg [17:0] count_fast;
    wire clk_fast;
    reg [7:0] count_slow;
    wire clk_slow;
    wire [5:0] rand;
    reg [5:0] id;
    reg update, update_done;
    wire [8*16-1:0] name;
    reg [8*16-1:0] chars;
    wire [7:0] char0, char1, char2, char3;

    reg btnC0, btnC1, btnC2;
    wire edge_btnC;
    reg [1:0] state;

    localparam INIT = 2'b00;
    localparam SEL  = 2'b01;
    localparam SET  = 2'b10;
    localparam SHOW = 2'b11;

    always @(posedge clk) begin
        count_fast <= count_fast + 18'b1;
    end
    assign clk_fast = count_fast[17];

    always @(posedge clk_fast) begin
        count_slow <= count_slow + 8'b1;
    end
    assign clk_slow = count_slow[7];

    always @(posedge clk_fast) begin
        btnC0 <= btnC;
        btnC1 <= btnC0;
        btnC2 <= btnC1;
    end
    assign edge_btnC = btnC2 & ~btnC1;

    initial state <= INIT;
    always @(posedge clk_fast) begin
        case (state)
        INIT: begin
            update <= 1'b0;
            if (edge_btnC == 1'b1) begin
                state <= SEL;
            end
        end
        SEL: begin
            update <= 1'b0;
            if (rand < 38) begin
                id <= rand;
                state <= SET;
            end
        end
        SET: begin
            update <= 1'b1;
            if (update_done == 1'b1) begin
                state <= SHOW;
            end
        end
        SHOW: begin
            update <= 1'b0;
            if (edge_btnC == 1'b1) begin
                state <= SEL;
            end
        end
        endcase
    end

    initial chars <= {16{8'b11111111}};
    always @(posedge clk_slow) begin
        if (update == 1'b1) begin
            chars <= name;
            update_done <= 1'b1;
        end else begin
            update_done <= 1'b0;
            chars <= {chars[8*15-1:0], chars[8*16-1:8*15]};
        end
    end
    assign {char3, char2, char1, char0} = chars[8*16-1:8*12];


    get_precure_name get_precure_name_i(
        .id(id),
        .name(name)
    );

    lfsr lfsr_i (
        .clk(clk_fast),
        .rand(rand)
    );

    seg7_4 seg7_4_i(
        .clk(clk_fast),
        .char0(char0),
        .char1(char1),
        .char2(char2),
        .char3(char3),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

endmodule


module lfsr (
    input wire clk,
    output reg [5:0] rand
);

    initial begin
        rand <= 6'b000001;
    end

    always @(posedge clk) begin
        rand[0] <= rand[1];
        rand[1] <= rand[2];
        rand[2] <= rand[3];
        rand[3] <= rand[4];
        rand[4] <= rand[5] ^ rand[0];
        rand[5] <= rand[0];
    end

endmodule


module seg7_4 (
    input  wire clk,
    input  wire [7:0] char0,
    input  wire [7:0] char1,
    input  wire [7:0] char2,
    input  wire [7:0] char3,
    output reg  [6:0] seg,
    output reg  dp,
    output reg  [3:0] an
);
    
    reg [1:0] c;

    always @(posedge clk) begin
        c <= c + 2'b1;
        case (c)
        2'b00: begin
            an <= 4'b1110;
            {dp, seg} <= char0;
        end
        2'b01: begin
            an <= 4'b1101;
            {dp, seg} <= char1;
        end
        2'b10: begin
            an <= 4'b1011;
            {dp, seg} <= char2;
        end 
        2'b11: begin
            an <= 4'b0111;
            {dp, seg} <= char3;
        end
        endcase
    end

endmodule



module get_precure_name (
    input wire [5:0] id, 
    output reg [8*16-1:0] name
);

    localparam SP = 8'b11111111;
    localparam A  = 8'b10001000;
    localparam B  = 8'b10000011;
    localparam C  = 8'b11000110;
    localparam D  = 8'b10100001;
    localparam E  = 8'b10000110;
    localparam F  = 8'b10001110;
    localparam G  = 8'b11000010;
    localparam H  = 8'b10001011;
    localparam I  = 8'b11111011; 
    localparam J  = 8'b11100001;
    localparam K  = 8'b10001010;
    localparam L  = 8'b11000111;
    localparam M  = 8'b11001000;
    localparam N  = 8'b10101011;
    localparam O  = 8'b10100011;
    localparam P  = 8'b10001100;
    localparam Q  = 8'b10011000;
    localparam R  = 8'b10101111;
    localparam S  = 8'b10010011;
    localparam T  = 8'b10000111;
    localparam U  = 8'b11100011;
    localparam V  = 8'b11000001;
    localparam W  = 8'b10000001;
    localparam X  = 8'b10001001;
    localparam Y  = 8'b10010001;
    localparam Z  = 8'b11100100;
    localparam BR = 8'b10111111;

    localparam DEFAULT     = {BR,BR,BR,BR, BR,BR,BR,BR, BR,BR,BR,BR, BR,BR,BR,BR};
    localparam CURE_BLACK = {C, U, R, E, SP, B, L, A, C, K, SP, SP, SP, SP, SP, SP}; 
    localparam CURE_WHITE = {C, U, R, E, SP, W, H, I, T, E, SP, SP, SP, SP, SP, SP};
    localparam SHINY_LUMINOUS = {S, H, I, N, Y, SP, L, U, M, I, N, O, U, S, SP, SP};
    localparam CURE_BLOOM = {C, U, R, E, SP, B, L, O, O, M, SP, SP, SP, SP, SP, SP};
    localparam CURE_EGRET = {C, U, R, E, SP, E, G, R, E, T, SP, SP, SP, SP, SP, SP};
    localparam CURE_DREAM = {C, U, R, E, SP, D, R, E, A, M, SP, SP, SP, SP, SP, SP};
    localparam CURE_ROUGE = {C, U, R, E, SP, R, O, U, G, E, SP, SP, SP, SP, SP, SP};
    localparam CURE_LEMONADE = {C, U, R, E, SP, L, E, M, O, N, A, D, E, SP, SP, SP};
    localparam CURE_MINT = {C, U, R, E, SP, M, I, N, T, SP, SP, SP, SP, SP, SP, SP};
    localparam CURE_AQUA = {C, U, R, E, SP, A, Q, U, A, SP, SP, SP, SP, SP, SP, SP};
    localparam MILKY_ROSE = {M, I, L, K, Y, SP, R, O, S, E, SP, SP, SP, SP, SP, SP};
    localparam CURE_PEACH = {C, U, R, E, SP, P, E, A, C, H, SP, SP, SP, SP, SP, SP};
    localparam CURE_BERRY = {C, U, R, E, SP, B, E, R, R, Y, SP, SP, SP, SP, SP, SP};
    localparam CURE_PINE = {C, U, R, E, SP, P, I, N, E, SP, SP, SP, SP, SP, SP, SP};
    localparam CURE_PASSION = {C, U, R, E, SP, P, A, S, S, I, O, N, SP, SP, SP, SP};
    localparam CURE_BLOSSOM = {C, U, R, E, SP, B, L, O, S, S, O, M, SP, SP, SP, SP};
    localparam CURE_MARINE = {C, U, R, E, SP, M, A, R, I, N, E, SP, SP, SP, SP, SP};
    localparam CURE_SUNSHINE = {C, U, R, E, SP, S, U, N, S, H, I, N, E, SP, SP, SP};
    localparam CURE_MOONLIGHT = {C, U, R, E, SP, M, O, O, N, L, I ,G, H, T, SP, SP};
    localparam CURE_MELODY = {C, U, R, E, SP, M, E, L, O, D, Y, SP, SP, SP, SP, SP};
    localparam CURE_RHYTHM = {C, U, R, E, SP, R, H, Y, T, H, M, SP, SP, SP, SP, SP};
    localparam CURE_BEAT = {C, U, R, E, SP, B, E, A, T, SP, SP, SP, SP, SP, SP, SP};
    localparam CURE_MUSE = {C, U, R, E, SP, M, U, S, E, SP, SP, SP, SP, SP, SP, SP};
    localparam CURE_HAPPY = {C, U, R, E, SP, H, A, P, P, Y, SP, SP, SP, SP, SP, SP};
    localparam CURE_SUSPY = {C, U, R, E, SP, S, U, N, N, Y, SP, SP, SP, SP, SP, SP};
    localparam CURE_PEACE = {C, U, R, E, SP, P, E, A, C, E, SP, SP, SP, SP, SP, SP};
    localparam CURE_MARCH = {C, U, R, E, SP, M, A, R, C, H, SP, SP, SP, SP, SP, SP};
    localparam CURE_BEAUTY = {C, U, R, E, SP, B, E, A, U, T, Y, SP, SP, SP, SP, SP};
    localparam CURE_HEART = {C, U, R, E, SP, H, E, A, R, T, SP, SP, SP, SP, SP, SP};
    localparam CURE_SWORD = {C, U, R, E, SP, S, W, O, R, D, SP, SP, SP, SP, SP, SP};
    localparam CURE_DIAMOND = {C, U, R, E, SP, D, I, A, M, O, N, D, SP, SP, SP, SP};
    localparam CURE_ROSETTA = {C, U, R, E, SP, R, O, S, E, T, T, A, SP, SP, SP, SP};
    localparam CURE_ACE = {C, U, R, E, SP, A, C, E, SP, SP, SP, SP, SP, SP, SP, SP};
    localparam CURE_LOVELY = {C, U, R, E, SP, L, O, V, E, L, Y, SP, SP, SP, SP, SP};
    localparam CURE_PRINCESS = {C, U, R, E, SP, P, R, I, N, C, E, S, S, SP, SP, SP};
    localparam CURE_HONEY = {C, U, R, E, SP, H, O, N, E, Y, SP, SP, SP, SP, SP, SP};
    localparam CURE_FORTUNE = {C, U, R, E, SP, F, O, R, T, U, N, E, SP, SP, SP, SP};

    always @(*) begin
        case (id)
        6'd01: name <= CURE_BLACK;
        6'd02: name <= CURE_WHITE;
        6'd03: name <= SHINY_LUMINOUS;
        6'd04: name <= CURE_BLOOM;
        6'd05: name <= CURE_EGRET;
        6'd06: name <= CURE_DREAM; 
        6'd07: name <= CURE_ROUGE; 
        6'd08: name <= CURE_LEMONADE; 
        6'd09: name <= CURE_MINT; 
        6'd10: name <= CURE_AQUA;
        6'd11: name <= MILKY_ROSE;
        6'd12: name <= CURE_PEACH;
        6'd13: name <= CURE_BERRY; 
        6'd14: name <= CURE_PINE;
        6'd15: name <= CURE_PASSION; 
        6'd16: name <= CURE_BLOSSOM; 
        6'd17: name <= CURE_MARINE; 
        6'd18: name <= CURE_SUNSHINE; 
        6'd19: name <= CURE_MOONLIGHT; 
        6'd20: name <= CURE_MELODY; 
        6'd21: name <= CURE_RHYTHM; 
        6'd22: name <= CURE_BEAT; 
        6'd23: name <= CURE_MUSE; 
        6'd24: name <= CURE_HAPPY; 
        6'd25: name <= CURE_SUSPY; 
        6'd26: name <= CURE_PEACE;
        6'd27: name <= CURE_MARCH;
        6'd28: name <= CURE_BEAUTY; 
        6'd29: name <= CURE_HEART; 
        6'd30: name <= CURE_SWORD;
        6'd31: name <= CURE_DIAMOND; 
        6'd32: name <= CURE_ROSETTA;
        6'd33: name <= CURE_ACE; 
        6'd34: name <= CURE_LOVELY; 
        6'd35: name <= CURE_PRINCESS; 
        6'd36: name <= CURE_HONEY; 
        6'd37: name <= CURE_FORTUNE; 
        default: name <= DEFAULT;
        endcase
    end

endmodule 

`default_nettype wire

