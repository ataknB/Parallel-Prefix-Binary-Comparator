module comparator_module #(parameter WIDTH = 32)(

	input [WIDTH-1:0]in0,
	input [WIDTH-1:0]in1,
	
	input comp_en,

	output  in0_bigger,
	output  in1_bigger,
	output  equal
	);
	
	assign abs_en_in0 = (in0[31]) ? in0 : 32'd0;
	assign abs_en_in1 = (in1[31]) ? in1 : 32'd0;
	
	wire [WIDTH-1:0]wire_out_in0;
	wire [WIDTH-1:0]wire_out_in1;
	
	
	abs_module_32bit abs_module_32bit_in0(
		.in(in0),
		.abs_en(abs_en_in0),
		.out(wire_out_in0)
	);
	
	abs_module_32bit abs_module_32bit_in1(
		.in(in1),
		.abs_en(abs_en_in1),
		.out(wire_out_in1)
	);
	
	
	
	wire [WIDTH/2-1:0]wire_k_in0;
	wire [WIDTH/2-1:0]wire_k_in1;
	
	wire [WIDTH/2-1:0]wire_in0_stage_1;
	wire [WIDTH/2-1:0]wire_in1_stage_1;
	
	wire [WIDTH/4-1:0]wire_in0_stage_2;
	wire [WIDTH/4-1:0]wire_in1_stage_2;
	
	wire [WIDTH/8-1:0]wire_in0_stage_3;
	wire [WIDTH/8-1:0]wire_in1_stage_3;
	
	wire [WIDTH/16-1:0]wire_in0_stage_4;
	wire [WIDTH/16-1:0]wire_in1_stage_4;
	
	wire [WIDTH/32-1:0]wire_in0_stage_5;
	wire [WIDTH/32-1:0]wire_in1_stage_5;
	
	
	genvar i;	
	generate 
		for(i=0; i<WIDTH/2; i=i+1)begin 
			assign wire_k_in0[i] = (wire_out_in0[1+i] & ~wire_out_in1[1+i]) | (~((wire_out_in0[1+i] & ~wire_out_in1[1+i]) | (~wire_out_in0[1+i] & wire_out_in1[1+i])) & (wire_out_in0[1+i] & ~wire_out_in1[1+i]));
			assign wire_k_in1[i] = (~wire_out_in0[1+i] & wire_out_in1[1+i]) | (~((wire_out_in0[1+i] & ~wire_out_in1[1+i]) | (~wire_out_in0[1+i] & wire_out_in1[1+i])) & (~wire_out_in0[1+i] & wire_out_in1[1+i]));
		end 
		
		for(i=0; i<WIDTH/2; i=i+1)begin 
			assign wire_in0_stage_1[i] = wire_k_in0[1+i] | (~wire_k_in1[1+i] & wire_k_in0[i]);
			assign wire_in1_stage_1[i] = wire_k_in1[1+i] | (~wire_k_in0[1+i] & wire_k_in1[i]);
		end 
		
		for(i=0; i<WIDTH/4; i=i+1)begin 
			assign wire_in0_stage_2[i] = wire_in0_stage_1[1+i] | (~wire_in1_stage_1[1+i] & wire_in0_stage_1[i]);
			assign wire_in1_stage_2[i] = wire_in1_stage_1[1+i] | (~wire_in0_stage_1[1+i] & wire_in1_stage_1[i]);
		end 
		
		for(i=0; i<WIDTH/8; i=i+1)begin 
			assign wire_in0_stage_3[i] = wire_in0_stage_2[1+i] | (~wire_in1_stage_2[1+i] & wire_in0_stage_2[i]);
			assign wire_in1_stage_3[i] = wire_in1_stage_2[1+i] | (~wire_in0_stage_2[1+i] & wire_in1_stage_2[i]);
		end 
		for(i=0; i<WIDTH/16; i=i+1)begin 
			assign wire_in0_stage_4[i] = wire_in0_stage_3[1+i] | (~wire_in1_stage_3[1+i] & wire_in0_stage_3[i]);
			assign wire_in1_stage_4[i] = wire_in1_stage_3[1+i] | (~wire_in0_stage_3[1+i] & wire_in1_stage_3[i]);
		end 
		for(i=0; i<WIDTH/32; i=i+1)begin 
			assign wire_in0_stage_5[i] = wire_in0_stage_4[1+i] | (~wire_in1_stage_4[1+i] & wire_in0_stage_4[i]);
			assign wire_in1_stage_5[i] = wire_in1_stage_4[1+i] | (~wire_in0_stage_4[1+i] & wire_in1_stage_4[i]);
		end 
		
	endgenerate
	
	assign in0_bigger = wire_in0_stage_5;
	assign in1_bigger = wire_in1_stage_5;
	assign equal = ~in0_bigger & ~in1_bigger;
	
endmodule
	
	
	
module abs_module_32bit #(parameter WIDTH = 32)
    (
    input [WIDTH-1:0]in,
    input abs_en,
    output [WIDTH-1:0]out
);
    genvar i;

    wire [WIDTH-1:0]wire_carry;
    assign wire_carry[0] = in[31];
    
    
    wire [WIDTH-1:0]wire_in;
    wire [WIDTH-1:0]wire_one = 32'd1;
    
    generate 
        for(i=0;i<WIDTH;i=i+1)begin 
            assign wire_in[i] = in[i] ^ wire_carry[0];
            assign out[i] = wire_in[i]  ^ wire_carry[i];
            assign wire_carry[i+1] = wire_in[i] & wire_carry[i];
        end
    endgenerate
    
    
endmodule
