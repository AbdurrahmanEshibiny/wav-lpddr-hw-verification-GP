class wddr_DFI_lp_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_lp_seq)

    function new(string name = "wddr_DFI_lp_seq");
        super.new(name);  
    endfunction

    virtual task body();
        wav_DFI_lp_transfer trans = new();
        int err;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(trans);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

        trans.req = 1'b1;
        trans.is_ctrl = 1'b1;
		`uvm_info(get_name(), "Sending lp ctrl transaction", UVM_LOW);
        `uvm_rand_send(trans);
		`uvm_info(get_type_name(), "printing lp ctrl transaction", UVM_MEDIUM);
		trans.print();
		
		trans.req = 1'b1;
        trans.is_ctrl = 1'b0;
		`uvm_info(get_name(), "Sending lp data transaction", UVM_LOW);
        `uvm_rand_send(trans);
		`uvm_info(get_type_name(), "printing lp data transaction", UVM_MEDIUM);
		trans.print();
		

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        
        fork
            EventHandler::wait_for_transaction(EventHandler::lp_data);
            EventHandler::wait_for_transaction(EventHandler::lp_ctrl);
        join

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass