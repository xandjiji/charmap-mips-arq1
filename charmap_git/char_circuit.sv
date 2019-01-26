module char_circuit(
    input wire dclk,                    // clock (nao tenho certeza se eh esse que devo usar)
    input wire [9:0] pixel_x, pixel_y,  // bits de linha e coluna da nossa matriz 640x480
    output wire font_bit,
	input wire [6:0] char
);

wire [6:0] char_addr;       // qual caractere (00-7F)             char_addr[7]+row_addr[4] = rom_addr[11]
wire [3:0] row_addr;        // LINHA do nosso caractere             char_addr[7]+row_addr[4] = rom_addr[11]
wire [10:0] rom_addr;       // entrada de font_ROM

wire [2:0] bit_addr;        // COLUNA do nosso caractere
wire [7:0] font_word;       // saida de font_ROM              // saida do mux 8x1

// instanciando font_ROM
font_ROM font_unit(.dclk(dclk), .char_select(rom_addr), .data_font_rom(font_word));

// pegando bits especificos dos fios pixel_x e pixel_y
//assign char_addr = {pixel_y[5:4], pixel_x[7:3]};
//assign char_addr = 7'h3;

assign row_addr = pixel_y[3:0];
//assign rom_addr = {char_addr, row_addr};
assign rom_addr = {char, row_addr};

assign bit_addr = pixel_x[2:0];
assign font_bit = font_word[~bit_addr];  // font_word é tratado como um ARRAY

/*
reg [2:0] bit_addr_reg;
always@(posedge dclk)
    bit_addr_reg <= bit_addr;

always@*
    case(bit_addr_reg)
        3'b000: font_bit = 3'b111,
        3'b001: font_bit = 3'b110,
        3'b010: font_bit = 3'b101,
        3'b011: font_bit = 3'b100,
        3'b100: font_bit = 3'b011,
        3'b101: font_bit = 3'b010,
        3'b110: font_bit = 3'b001,
        3'b111: font_bit = 3'b000
    endcase
*/

endmodule