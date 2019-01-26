`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Source: https://www.element14.com/community/thread/23394/l/draw-vga-color-bars-with-fpga-in-verilog
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga640x480(
  input wire dclk,      //pixel clock: 25MHz
  input wire clr,      //asynchronous reset
  input wire [31:0] vdata,   //video data from memory 
  output wire [31:0] vadr,   //video address to memory
  output wire hsync,    //horizontal sync out
  output wire vsync,    //vertical sync out
  output reg [3:0] red,  //red vga output
  output reg [3:0] green, //green vga output
  output reg [3:0] blue,  //blue vga output
  
  output wire [9:0] pixel_x,    // pedir ajuda
  output wire [9:0] pixel_y 
  );

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 525; // vertical lines per frame

parameter hfp = 16;   // beginning of horizontal front porch
parameter hpulse = 96;   // hsync pulse length
parameter hbp = 48;   // end of horizontal back porch

parameter vfp = 10;   // beginning of vertical front porch
parameter vpulse = 2;   // vsync pulse length
parameter vbp = 33;     // end of vertical back porch

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

//wire pixel;

// diz se pinta ou nao o pixel com base nos contadores V e H
wire font_bit;

// recebe 7 bits determinando o caractere
wire [6:0] char;
wire [7:0] char8;

assign pixel_x = hc;
assign pixel_y = vc;

// 7 bits para enderecar a coluna (80 colunas)
reg [6:0] coluna;
// 5 bits para enderecar a linha (30 linhas)
reg [4:0] linha;

assign linha = vc[8:4];		// 111111XXXX pois os caracteres tem 16 pixels de altura
assign coluna = hc[9:3];	// 1111111XXX pois os caracteres tem 8 pixels de altura

char_circuit char_unit(.dclk(dclk), .pixel_x(pixel_x), .pixel_y(pixel_y), .font_bit(font_bit), .char(char));

// Downsampling to 20x20 pixels per bit 

/*
// 480 / 20 = 24 rows  
assign vadr = (vc + 40)<<2;

// 640 / 20 = 32 columns 
assign pixel = vdata[31-(hc)];
*/

// linha
assign vadr = (linha + 40)<<2;

// coluna
assign char8 = vdata[(31-(coluna))];
assign char = char8[6:0];

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc > hpixels-hbp-hpulse && hc < hpixels-hbp) ? 0 : 1;
assign vsync = (vc > vlines-vbp-vpulse && vc < vlines-vbp) ? 0 : 1;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
  // reset condition
  if (clr == 1)
  begin
    hc <= 0;
    vc <= 0;
  end
  else
  begin
    // keep counting until the end of the line
    if (hc < hpixels - 1)
      hc <= hc + 1;
    else
    // When we hit the end of the line, reset the horizontal
    // counter and increment the vertical counter.
    // If vertical counter is at the end of the frame, then
    // reset that one too.
    begin
      hc <= 0;
      if (vc < vlines - 1)
        vc <= vc + 1;
      else
        vc <= 0;
    end
    
  end
end

// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
  // first check if we're within vertical active video range
  if (vc < vlines-vbp-vpulse-vfp)
  begin
    // now display different colors every 80 pixels
    // while we're within the active horizontal range
    // -----------------
    // display white bar
    if (hc < hpixels-hbp-hpulse-hfp)
    begin
      red = {4{font_bit}};
      green = {4{font_bit}};
      blue = ~{4{font_bit}};    
    end
      // we're outside active horizontal range so display black
    else
    begin
      red = 0;
      green = 0;
      blue = 0;
    end
  end
  // we're outside active vertical range so display black
  else
  begin
    red = 0;
    green = 0;
    blue = 0;
  end
end

endmodule