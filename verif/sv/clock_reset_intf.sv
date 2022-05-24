interface clock_reset_intf;
	int refclk_period_ns = 26;
	int refclk_alt_period_ns = 26;
	int ana_refclk_period_ns = 26;
	int ahbclk_period_ns = 10;
	int tck_period_ns = 25;

	logic i_rst = '0;
	logic i_prst = '1;

	logic i_refclk = '0;
	logic i_refclk_alt = '0;
	logic i_ana_refclk = '0;

	logic i_jtag_tck = '0;
	logic i_jtag_trst_n = '1;

	logic i_ahb_clk = '0;
	logic i_ahb_rst = '0;

	logic o_dfi_clk;
	
	always #(refclk_period_ns) i_refclk = ~i_refclk;
	always #(refclk_alt_period_ns) i_refclk_alt = ~i_refclk_alt;
	always #(ana_refclk_period_ns) i_ana_refclk = ~i_ana_refclk;
	always #(ahbclk_period_ns) i_ahb_clk = ~i_ahb_clk;
	always #(tck_period_ns) i_jtag_tck = ~i_jtag_tck;
	
	task automatic wait_tck;
		input [31:0] num_cycles;
		begin
			repeat (num_cycles) @(posedge i_jtag_tck);
			#1ps;
		end
	endtask
	
	task automatic wait_hclk;
		input [31:0] num_cycles;
		begin
			repeat (num_cycles) @(posedge i_ahb_clk);
			#1;
		end
	endtask
	
	task automatic wait_dficlk;
		input [31:0] num_cycles;
		begin
			repeat (num_cycles) @(posedge o_dfi_clk);
			#1;
		end
	endtask
	
	task automatic wait_refclk;
		input [31:0] num_cycles;
		begin
			repeat (num_cycles) @(posedge i_refclk);
			#1;
		end
	endtask
	
	task automatic wait_refclk_alt;
		input [31:0] num_cycles;
		begin
			repeat (num_cycles) @(posedge i_refclk_alt);
			#1;
		end
	endtask

	task automatic por;
		begin
			force i_ahb_clk    = '0;
			force i_ana_refclk = '0;
			force i_refclk     = '0;
			force i_refclk_alt = '0;
			force i_jtag_tck   = '0;
			wait_refclk(2);
			i_prst        = 1'b0;
			i_rst         = 1'b1;
			i_jtag_trst_n = 1'b0;
			wait_refclk(5);
			i_prst        = 1'b1;
			wait_refclk(5);
			i_rst         = 1'b0;
			i_jtag_trst_n = 1'b1;
			wait_refclk(5);
			release i_ahb_clk    ;
			release i_ana_refclk ;
			release i_refclk     ;
			release i_refclk_alt ;
			release i_jtag_tck   ;
			wait_refclk(10);
		end
	endtask

	task automatic set_i_rst (input bit value);
		i_rst = value;
	endtask

	task automatic set_i_prst (input bit value);
		i_prst = value;
	endtask

	task automatic set_i_jtag_trst_n (input bit value);
		i_jtag_trst_n = value;
	endtask

	task automatic set_i_ahb_rst (input bit value);
		i_ahb_rst = value;
	endtask

	//i_refclk
	task automatic i_refclk_off;
		force i_refclk = '0;
	endtask

	task automatic i_refclk_on;
		release i_refclk;
	endtask

	task automatic set_refclk_period_ns (input int value);
		refclk_period_ns = value;
	endtask

	//i_refclk_alt
	task automatic i_refclk_alt_off;
		force i_refclk_alt = '0;
	endtask

	task automatic i_refclk_alt_on;
		release i_refclk_alt;
	endtask

	task automatic set_refclk_alt_period_ns (input int value);
		refclk_alt_period_ns = value;
	endtask

	//i_ana_refclk
	task automatic i_ana_refclk_off;
		force i_ana_refclk = '0;
	endtask

	task automatic i_ana_refclk_on;
		release i_ana_refclk;
	endtask

	task automatic set_ana_refclk_period_ns (input int value);
		ana_refclk_period_ns = value;
	endtask

	//i_ahb_clk
	task automatic i_ahb_clk_off;
		force i_ahb_clk = '0;
	endtask

	task automatic i_ahb_clk_on;
		release i_ahb_clk;
	endtask

	task automatic set_ahbclk_period_ns (input int value);
		ahbclk_period_ns = value;
	endtask

	//i_jtag_tck
	task automatic i_jtag_tck_off;
		force i_jtag_tck = '0;
	endtask

	task automatic i_jtag_tck_on;
		release i_jtag_tck;
	endtask
	
	task automatic set_tck_period_ns (input int value);
		tck_period_ns = value;
	endtask
endinterface