class my_rand;
    randc bit [3:0] ba;

    constraint c1{ba inside {[0:15]};};
endclass

class wddr_DFI_power_down_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_power_down_seq)

    function new(string name = "wddr_DFI_power_down_seq");
        super.new(name);  
    endfunction


    
    // virtual task old_body();
    //     // wav_DFI_lp_transfer vif <= new();
    //     virtual wav_DFI_if vif;
    //     // wav_DFI_write_transfer vif <= new();
    //     my_rand random;
    //     int err;
    //     super.body();
    //     ddr_boot(err);
    //     if (err != 0) begin
    //         `uvm_error(get_name(), $sformatf("sequence err_cnt <= %d ", err_cnt));
    //     end
    //     config_vips(200,1);
        
    //     random = new();
    //     if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
    //         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
    //     end

    // ///////////////////////////Power Down Entry /////////////////////////////////
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "power down entry", UVM_MEDIUM);
    //     vif.cke[0]  <= 2'b01;
    //     vif.cs[0]	<= 2'b10;
    //     vif.cs[2]	<= 2'b00;
    //     vif.dram_clk_disable[0] <= 0;
    //     vif.dram_clk_disable[1] <= 1;
    //     vif.dram_clk_disable[2] <= 1;
    //     vif.dram_clk_disable[3] <= 1;

    //     vif.address[0] <= 14'h04;
    //     vif.address[2] <= 14'h00;
    //     // `uvm_send(vif);

    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "power down exit", UVM_MEDIUM);
    //     vif.address[0] <= 14'h00;
    //     vif.cs[0]	<= 2'b10;
    //     vif.cs[2]	<= 2'b10;
    //     // `uvm_send(vif);
        
    // //////////////////////////Per Bank refresh /////////////////////////////////
    //     /*
    //         enter a for loop that does 2 things: 
    //         1) at posedge send all bank refresh command
    //         2) at nededge randomize the bank address and send it on the CA Bus
    //     */
    //     repeat(10) @(posedge vif.clock);
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "Per Bank refresh ", UVM_MEDIUM);
    //     vif.address[0] <= 7'b0111000;
    //     vif.address[2] <= 0;
    //     for(int i = 0; i < 16; i++) begin
    //         assert(random.randomize());
    //         @(posedge vif.clock);
    //         `uvm_info(get_name(), $psprintf("Per Bank refresh, bank=%0h", random.ba), UVM_MEDIUM);
    //         vif.address[0] <= 7'b0111000;
    //         vif.address[2] <= {3'b000, random.ba};
    //     end     

	// 	@(posedge vif.clock);
    //     vif.address[0] <= 0;
    //     vif.address[2] <= 0;
        
    //     //////////////////////////All Bank Refresh /////////////////////////////////
    //     repeat(10) @(posedge vif.clock);
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "All Bank refresh ", UVM_MEDIUM);
    //     vif.address[0] <= 7'b0111000;
    //     vif.address[2] <= 7'b1111000;

	// 	@(posedge vif.clock);
    //     vif.address[0] <= 0;
    //     vif.address[2] <= 0;
		
    //     //////////////////////////Deep Sleep Entry with power down/////////////////////////////////
    //     repeat(4) @(posedge vif.clock);
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Entry with power down", UVM_MEDIUM);
    //     vif.address[0] <= 7'b1101000;
    //     vif.address[2] <= 7'b1000000;
        
    //     @(posedge vif.clock);
    //     vif.cs[0] <= 2'b00;
    //     vif.cs[2] <= 2'b00;

    //     //////////////////////////Deep Sleep Exit  with power down/////////////////////////////////
    //     repeat(4) @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Exit with power down", UVM_MEDIUM);
    //     vif.cs[0] <= 2'b10;
    //     vif.cs[2] <= 2'b10;

    //     vif.address[0] <= 0;
    //     vif.address[2] <= 0;
        
    //     //////////////////////////Deep Sleep Entry with self refresh /////////////////////////////////
    //     repeat(10) @(posedge vif.clock);
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Entry with self refresh", UVM_MEDIUM);
    //     vif.address[0] <= 7'b1101000;
    //     vif.address[2] <= 7'b1000000;
    //     @(posedge vif.clock);
    //     vif.cs[0] <= 2'b00;
    //     vif.cs[2] <= 2'b00;

    //     //////////////////////////Deep Sleep Exit with self refresh /////////////////////////////////
    //     repeat(4) @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Exit with self refresh", UVM_MEDIUM);
    //     vif.cs[0] <= 2'b10;
    //     vif.cs[2] <= 2'b10;

    //     vif.address[0] <= 0;
    //     vif.address[2] <= 0;


    //     //////////////////////////Deep Sleep Entry  /////////////////////////////////
    //     repeat(10) @(posedge vif.clock);        
    //     @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Entry", UVM_MEDIUM);
    //     vif.address[0] <= 7'b1101000;
    //     vif.address[2] <= 7'b0000000;
        
    //     //////////////////////////Deep Sleep Exit /////////////////////////////////
    //     @(posedge vif.clock);
    //     vif.address[0] <= 7'b0000000;
    //     vif.address[2] <= 7'b0000000;
    //     repeat(4)  @(posedge vif.clock);
    //     `uvm_info(get_name(), "Deep Sleep Exit", UVM_MEDIUM);
    //     vif.address[0] <= 7'b0101000;

    //     repeat(2) @(posedge vif.clock); 
    // endtask


    
    virtual task body();
        wav_DFI_cmd_transfer trans;
        virtual clock_reset_intf vreset;
        my_rand random;
        int err;

        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt <= %d ", err_cnt));
        end
        // config_vips(200,1);
        
        random = new();
        `uvm_create(trans);
        trans.is_rsp_required = 0;
        init_vif();
    ///////////////////////////Power Down Entry /////////////////////////////////
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "power down entry", UVM_MEDIUM);
        trans.cke[0]  = 2'b01;
        trans.cs[0]	= 2'b10;
        trans.cs[2]	= 2'b10;
        trans.dram_clk_disable[0] = 0;
        trans.dram_clk_disable[1] = 1;
        trans.dram_clk_disable[2] = 1;
        trans.dram_clk_disable[3] = 1;

        trans.address[0] = 7'b1000000;
        trans.address[2] = 7'b0000000;
        `uvm_send(trans);

        wait_dfi_cycles(2);
        trans.address[0] = 14'h00;
        trans.cs[0]	= 2'b00;
        trans.cs[2]	= 2'b00;
        `uvm_send(trans);
        
        wait_dfi_cycles(10);
        `uvm_info(get_name(), "power down exit", UVM_MEDIUM);
        trans.address[0] = 14'h00;
        trans.cs[0]	= 2'b10;
        trans.cs[2]	= 2'b10;
        `uvm_send(trans);
        
    //////////////////////////Per Bank refresh /////////////////////////////////
        /*
            enter a for loop that does 2 things: 
            1) at posedge send all bank refresh command
            2) at nededge randomize the bank address and send it on the CA Bus
        */
        wait_dfi_cycles(10);
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "Per Bank refresh ", UVM_MEDIUM);
        trans.address[0] = 7'b0111000;
        trans.address[2] = 0;
        `uvm_send(trans);

        for(int i = 0; i < 16; i++) begin
            assert(random.randomize());
            wait_dfi_cycles(1);
            `uvm_info(get_name(), $psprintf("Per Bank refresh, bank=%0h", random.ba), UVM_MEDIUM);
            trans.address[0] = 7'b0111000;
            trans.address[2] = {3'b000, random.ba};
            `uvm_send(trans);
        end     

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        trans.address[2] = 0;
        `uvm_send(trans);
        
        //////////////////////////All Bank Refresh /////////////////////////////////
        wait_dfi_cycles(10);
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "All Bank refresh ", UVM_MEDIUM);
        trans.address[0] = 7'b0111000;
        trans.address[2] = 7'b1111000;
        `uvm_send(trans);

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        trans.address[2] = 0;
        `uvm_send(trans);
		
        //////////////////////////Deep Sleep Entry with power down/////////////////////////////////
        wait_dfi_cycles(4);
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "Deep Sleep Entry with power down", UVM_MEDIUM);
        trans.address[0] = 7'b1101000;
        trans.address[2] = 7'b1000000;
        `uvm_send(trans);
        
        wait_dfi_cycles(1);
        trans.cs[0] = 2'b00;
        trans.cs[2] = 2'b00;
        `uvm_send(trans);

        //////////////////////////Deep Sleep Exit  with power down/////////////////////////////////
        wait_dfi_cycles(4);
        `uvm_info(get_name(), "Deep Sleep Exit with power down", UVM_MEDIUM);
        trans.cs[0] = 2'b10;
        trans.cs[2] = 2'b10;
        // `uvm_send(trans);

        trans.address[0] = 0;
        trans.address[2] = 0;
        `uvm_send(trans);
        
        //////////////////////////Deep Sleep Entry with self refresh /////////////////////////////////
        wait_dfi_cycles(10);
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "Deep Sleep Entry with self refresh", UVM_MEDIUM);
        trans.address[0] = 7'b1101000;
        trans.address[2] = 7'b1000000;
        `uvm_send(trans);

        wait_dfi_cycles(1);
        trans.cs[0] = 2'b00;
        trans.cs[2] = 2'b00;
        `uvm_send(trans);

        //////////////////////////Deep Sleep Exit with self refresh /////////////////////////////////
        wait_dfi_cycles(4);
        `uvm_info(get_name(), "Deep Sleep Exit with self refresh", UVM_MEDIUM);
        trans.cs[0] = 2'b10;
        trans.cs[2] = 2'b10;
        // `uvm_send(trans);

        trans.address[0] = 0;
        trans.address[2] = 0;
        `uvm_send(trans);


        //////////////////////////Deep Sleep Entry  /////////////////////////////////
        wait_dfi_cycles(10);        
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "Deep Sleep Entry", UVM_MEDIUM);
        trans.address[0] = 7'b1101000;
        trans.address[2] = 7'b0000000;
        `uvm_send(trans);
        
        //////////////////////////Deep Sleep Exit /////////////////////////////////
        wait_dfi_cycles(1);
        trans.address[0] = 7'b0000000;
        trans.address[2] = 7'b0000000;
        `uvm_send(trans);

        wait_dfi_cycles(4);
        `uvm_info(get_name(), "Deep Sleep Exit", UVM_MEDIUM);
        trans.address[0] = 7'b0101000;
        `uvm_send(trans);

        ///////////////////////////Multi Purpose Command /////////////////////////////////
        wait_dfi_cycles(1);
        `uvm_info(get_name(), "Multi Purpose Command", UVM_MEDIUM);
        trans.address[0] = 7'b0110000;
        `uvm_send(trans);
        
        
        // `uvm_send(vif);
        
        //////////////////////////  Read FIFO ///////////////////////////////////

        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Read FIFO", UVM_MEDIUM);
        trans.address[0] = 7'b0100000;
        `uvm_send(trans);   

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans); 

        //////////////////////////////  Write FIFO /////////////////////////////////

        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Write FIFO", UVM_MEDIUM);
        trans.address[0] = 7'b1100000;
        `uvm_send(trans);   

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans);

        //////////////////////////  Read DQ Calibration /////////////////////////////////

        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Read DQ Calibration", UVM_MEDIUM);
        trans.address[0] = 7'b1010000;
        `uvm_send(trans);   

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans); 

        
        //////////////////////////Mode Register Write-1 /////////////////////////////////
       
        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Mode Register Write-1 ", UVM_MEDIUM);
        trans.address[0] = 7'b1011000;
        `uvm_send(trans); 

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans);
        
        //////////////////////////Mode Register Write-2 /////////////////////////////////
       
        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Mode Register Write-2 ", UVM_MEDIUM);
        trans.address[0] = 7'b0001000;
        `uvm_send(trans);   

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans);    

        //////////////////////////Mode Register Read/////////////////////////////////
        
        wait_dfi_cycles(2);
        `uvm_info(get_name(), "Mode Register Read ", UVM_MEDIUM);
        trans.address[0] = 7'b0011000;
        `uvm_send(trans);   

		wait_dfi_cycles(1);
        trans.address[0] = 0;
        `uvm_send(trans);

        wait_dfi_cycles(20); 
		
		//////////////////////////Toggling command interface DFI signals/////////////////////////////////
		trans.cke 				= '{default: 2'b11};
        trans.cs				= '{default: 2'b11};
        trans.dram_clk_disable	= '{default: 1};
		trans.parity_in			= '{default: 1};
        trans.address 			= '{default: 14'h0000};
        `uvm_send(trans);
		wait_dfi_cycles(10); 
		
		trans.cke 				= '{default: 2'b00};
        trans.cs				= '{default: 2'b00};
        trans.dram_clk_disable	= '{default: 0};
		trans.parity_in			= '{default: 0};
        trans.address 			= '{default: 14'hffff};
		`uvm_send(trans);
		wait_dfi_cycles(10); 
		
		trans.address 			= '{default: 14'h0000};
		`uvm_send(trans);
		wait_dfi_cycles(10); 
		
		trans.reset_n			= '{default: 1};
		`uvm_send(trans);
		wait_dfi_cycles(10);
		
		trans.reset_n			= '{default: 0};
		`uvm_send(trans);
		wait_dfi_cycles(10);
        
        if (!uvm_config_db#(virtual clock_reset_intf)::get(uvm_root::get(), "*", "clk_rst_vif", vreset)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".clk_rst_vif"});
        end

        // exercising the resets
        vreset.i_refclk_alt_off();
        #10ns;
        vreset.i_refclk_alt_on();
        #10ns;
        vreset.i_ana_refclk_off();
        #10ns;
        vreset.i_ana_refclk_on();
        #10ns;
        vreset.i_ahb_clk_off();
        #10ns;
        vreset.i_ahb_clk_on();
        #10ns;
        vreset.i_jtag_tck_off();
        #10ns;
        vreset.i_jtag_tck_on();
        #10ns;
        vreset.set_i_jtag_trst_n(0);
        #10ns;
        vreset.set_i_jtag_trst_n(1);
        #10ns;
        vreset.set_i_ahb_rst(1);
        #10ns;
        vreset.set_i_ahb_rst(0);
        #10ns;
        vreset.i_refclk_off();
        #10ns;
        vreset.i_refclk_on();
        #10ns;
        vreset.set_i_prst(1);
        #10ns;
        vreset.set_i_prst(0);
        #10ns;
        vreset.set_i_rst(1);
        #10ns;
        vreset.set_i_rst(0);

        #50ns;
    endtask
endclass