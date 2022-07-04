class my_rand;
    randc bit [3:0] ba;

    constraint c1{ba inside {[0:15]};};
endclass

class wddr_DFI_power_down_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_power_down_seq)

    function new(string name = "wddr_DFI_power_down_seq");
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

    ///////////////////////////Power Down Entry /////////////////////////////////
        @(posedge vif.clock);
        `uvm_info(get_name(), "power down entry", UVM_MEDIUM);
        vif.cke[0]  <= 2'b01;
        vif.cs[0]	<= 2'b10;
        vif.cs[2]	<= 2'b00;
        vif.dram_clk_disable[0] <= 0;
        vif.dram_clk_disable[1] <= 1;
        vif.dram_clk_disable[2] <= 1;
        vif.dram_clk_disable[3] <= 1;

        vif.address[0] <= 14'h04;
        vif.address[2] <= 14'h00;
        // `uvm_send(vif);

        @(posedge vif.clock);
        `uvm_info(get_name(), "power down exit", UVM_MEDIUM);
        vif.address[0] <= 14'h00;
        vif.cs[0]	<= 2'b10;
        vif.cs[2]	<= 2'b10;
        // `uvm_send(vif);
        
    //////////////////////////Per Bank refresh /////////////////////////////////
        /*
            enter a for loop that does 2 things: 
            1) at posedge send all bank refresh command
            2) at nededge randomize the bank address and send it on the CA Bus
        */
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Per Bank refresh ", UVM_MEDIUM);
        vif.address[0] <= 7'b0111000;
        vif.address[2] <= 0;
        for(int i = 0; i < 16; i++) begin
            assert(random.randomize());
            @(posedge vif.clock);
            `uvm_info(get_name(), $psprintf("Per Bank refresh, bank=%0h", random.ba), UVM_MEDIUM);
            vif.address[0] <= 7'b0111000;
            vif.address[2] <= {3'b000, random.ba};
        end     

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;
        
        //////////////////////////All Bank Refresh /////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "All Bank refresh ", UVM_MEDIUM);
        vif.address[0] <= 7'b0111000;
        vif.address[2] <= 7'b1111000;

		@(posedge vif.clock);
        vif.address[0] <= 0;
        vif.address[2] <= 0;
		
        //////////////////////////Deep Sleep Entry with power down/////////////////////////////////
        repeat(4) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Entry with power down", UVM_MEDIUM);
        vif.address[0] <= 7'b1101000;
        vif.address[2] <= 7'b1000000;
        
        @(posedge vif.clock);
        vif.cs[0] <= 2'b00;
        vif.cs[2] <= 2'b00;

        //////////////////////////Deep Sleep Exit  with power down/////////////////////////////////
        repeat(4) @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Exit with power down", UVM_MEDIUM);
        vif.cs[0] <= 2'b10;
        vif.cs[2] <= 2'b10;

        vif.address[0] <= 0;
        vif.address[2] <= 0;
        
        //////////////////////////Deep Sleep Entry with self refresh /////////////////////////////////
        repeat(10) @(posedge vif.clock);
        @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Entry with self refresh", UVM_MEDIUM);
        vif.address[0] <= 7'b1101000;
        vif.address[2] <= 7'b1000000;
        @(posedge vif.clock);
        vif.cs[0] <= 2'b00;
        vif.cs[2] <= 2'b00;

        //////////////////////////Deep Sleep Exit with self refresh /////////////////////////////////
        repeat(4) @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Exit with self refresh", UVM_MEDIUM);
        vif.cs[0] <= 2'b10;
        vif.cs[2] <= 2'b10;

        vif.address[0] <= 0;
        vif.address[2] <= 0;


        //////////////////////////Deep Sleep Entry  /////////////////////////////////
        repeat(10) @(posedge vif.clock);        
        @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Entry", UVM_MEDIUM);
        vif.address[0] <= 7'b1101000;
        vif.address[2] <= 7'b0000000;
        
        //////////////////////////Deep Sleep Exit /////////////////////////////////
        @(posedge vif.clock);
        vif.address[0] <= 7'b0000000;
        vif.address[2] <= 7'b0000000;
        repeat(4)  @(posedge vif.clock);
        `uvm_info(get_name(), "Deep Sleep Exit", UVM_MEDIUM);
        vif.address[0] <= 7'b0101000;

        repeat(2) @(posedge vif.clock); 
    endtask

endclass