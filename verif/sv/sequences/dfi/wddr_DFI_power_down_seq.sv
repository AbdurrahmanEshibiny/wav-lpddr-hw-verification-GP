class wddr_DFI_power_down_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_power_down_seq)

    function new(string name = "wddr_DFI_power_down_seq");
        super.new(name);  
    endfunction

    virtual task body();
        // wav_DFI_lp_transfer trans = new();
        virtual wav_DFI_if vif;
        wav_DFI_write_transfer trans = new();
        int err;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        config_vips(200,1);

        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
        end

    ///////////////////////////Power Down Entry /////////////////////////////////
    `uvm_info(get_name(), "Starting power down entry", UVM_MEDIUM);

    trans.cs[0]	= 2'b11;
    trans.dram_clk_disable[0] = 0;
    trans.dram_clk_disable[1] = 0;
    trans.dram_clk_disable[2] = 0;
    trans.dram_clk_disable[3] = 0;
    trans.address[0] = 14'h04;
    `uvm_send(trans);

    // //posedge
    // @(posedge vif.mp_drv.cb_drv);
    // trans.cs[0]	= 2'b01;
    // trans.address[0] = 14'b0000001_0000001;
    // `uvm_send(trans);
 	// // {ch0_vif.ca0,ch0_vif.ca1,ch0_vif.ca2,ch0_vif.ca3,ch0_vif.ca4,ch0_vif.ca5,ch0_vif.ca6}	=	7'b0000001;

    // //negedge -> CS must be 0 while in power down
    // @(posedge vif.mp_drv.cb_drv);
    // `uvm_info(get_name(), "toggling the chip select", UVM_MEDIUM);    
    // trans.cs[0]	= 2'b00;
    // `uvm_send(trans);


	// //////////////////////////Power Down Exit /////////////////////////////////
    // `uvm_info(get_name(), "Starting power down exit", UVM_MEDIUM);
    // // #3	// if CS toggles then we exit power down
    // @(posedge vif.mp_drv.cb_drv);
    // `uvm_info(get_name(), "toggling the chip select", UVM_MEDIUM);  
    // trans.cs[0] =	2'b01;
    // `uvm_send(trans);
    #100us;

        // `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        // `uvm_create(trans);
        // `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

        // trans.req = 1'b1;
        // trans.is_ctrl = 1'b1;

        // `uvm_rand_send(trans);

        // `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        // `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        // trans.print();
        // get_response(rsp);  
        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass