
module AluDisplay (
    input clk,
    input resetn,

    input [1:0] input_sel,

    output lcd_rst,
    output lcd_cs,
    output lcd_rs,
    output lcd_wr,
    output lcd_rd,
    inout [15:0] lcd_data_io,
    output lcd_bl_ctr,
    inout ct_int,
    inout ct_sda,
    output ct_scl,
    output ct_rstn
  );

  reg [3:0] alu_control;
  reg [31:0] alu_src1;
  reg [31:0] alu_src2;
  wire [31:0] alu_result;

  Alu alu(
        .control(alu_control),
        .src1(alu_src1),
        .src2(alu_src2),
        .result(alu_result)
      );


  reg display_valid;
  reg [39:0] display_name;
  reg [31:0] display_value;
  wire [5:0] display_number;
  wire input_valid;
  wire [31:0] input_value;

  lcd_module lcd_module (
               .clk(clk),  // 10Mhz
               .resetn(resetn),

               // lcd interface
               .display_valid(display_valid),
               .display_name(display_name),
               .display_value(display_value),
               .display_number(display_number),
               .input_valid(input_valid),
               .input_value(input_value),

               // lcd interface
               .lcd_rst(lcd_rst),
               .lcd_cs(lcd_cs),
               .lcd_rs(lcd_rs),
               .lcd_wr(lcd_wr),
               .lcd_rd(lcd_rd),
               .lcd_data_io(lcd_data_io),
               .lcd_bl_ctr(lcd_bl_ctr),
               .ct_int(ct_int),
               .ct_sda(ct_sda),
               .ct_scl(ct_scl),
               .ct_rstn(ct_rstn)
             );

  always @(posedge clk) begin
    if (!resetn) begin
      alu_control <= 4'd0;
    end
    else if (input_valid && input_sel == 2'b00) begin
      alu_control <= input_value[3:0];
    end
  end

  always @(posedge clk) begin
    if (!resetn) begin
      alu_src1 <= 32'd0;
    end
    else if (input_valid && input_sel == 2'b10) begin
      alu_src1 <= input_value;
    end
  end

  always @(posedge clk) begin
    if (!resetn) begin
      alu_src2 <= 32'd0;
    end
    else if (input_valid && input_sel == 2'b11) begin
      alu_src2 <= input_value;
    end
  end

  always @(posedge clk) begin
    case (display_number)
      6'd1: begin
        display_valid <= 1'b1;
        display_name <= "SRC_1";
        display_value <= alu_src1;
      end
      6'd2 : begin
        display_valid <= 1'b1;
        display_name  <= "SRC_2";
        display_value <= alu_src2;
      end
      6'd3 : begin
        display_valid <= 1'b1;
        display_name  <= "CONTR";
        display_value <={20'd0, alu_control};
      end
      6'd4 : begin
        display_valid <= 1'b1;
        display_name  <= "RESUL";
        display_value <= alu_result;
      end
      default : begin
        display_valid <= 1'b0;
        display_name  <= 40'd0;
        display_value <= 32'd0;
      end
    endcase
  end

endmodule
