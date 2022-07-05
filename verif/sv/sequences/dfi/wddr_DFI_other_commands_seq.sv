class wddr_DFI_other_commands_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_other_commands_seq)

    function new(string name = "wddr_DFI_other_commands_seq");
        super.new(name);  
    endfunction

    virtual task body();
        // wav_DFI_lp_transfer vif <= new();
        virtual wav_DFI_if vif;
        // wav_DFI_write_transfer vif <= new();
        my_rand random;
        int err;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt <= %d ", err_cnt));
        end
        config_vips(200,1);
        
        random = new();
        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
        end

    ///////////////////////////Multi Purpose Command /////////////////////////////////
        @(posedge vif.clock);
        `uvm_info(get_name(), "Multi Purpose Command", UVM_MEDIUM);
        vif.cke[0]  <= 2'b01;
        vif.cs[0]	<= 2'b10;
        vif.cs[2]	<= 2'b00;
        vif.dram_clk_disable[0] <= 0;
        vif.dram_clk_disable[1] <= 1;
        vif.dram_clk_disable[2] <= 1;
        vif.dram_clk_disable[3] <= 1;
        
        vif.address[0] <= 7'b0110000;
        vif.address[2] <= 0;
        // `uvm_send(vif);


        
    //////////////////////////Mode Register Write-1 /////////////////////////////////
       
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Mode Register Write-1 ", UVM_MEDIUM);
        vif.address[0] <= 7'b1011000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;
        
    //////////////////////////Mode Register Write-2 /////////////////////////////////
       
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Mode Register Write-2 ", UVM_MEDIUM);
        vif.address[0] <= 7'b0001000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;
		
        //////////////////////////Mode Register Read/////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Mode Register Read ", UVM_MEDIUM);
        vif.address[0] <= 7'b0011000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;

        //////////////////////////  Read FIFO /////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Read FIFO", UVM_MEDIUM);
        vif.address[0] <= 7'b0100000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;
        
        //////////////////////////  Write FIFO /////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Write FIFO", UVM_MEDIUM);
        vif.address[0] <= 7'b1100000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;

        //////////////////////////  Read DQ Calibration /////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Read DQ Calibration", UVM_MEDIUM);
        vif.address[0] <= 7'b1010000;
        vif.address[2] <= 0;
           

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;

        repeat(2) @(posedge vif.clock); 
    endtask

endclass