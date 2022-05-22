class wddr_DFI_ctrlupd_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_ctrlupd_seq)

    function new(string name = "wddr_DFI_ctrlupd_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err;
        wav_DFI_update_transfer trans = new();
        virtual wav_DFI_if vif;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
            `uvm_fatal(get_name(), "cannot get the wav_DFI_if");
        end            

        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(trans);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

        trans.req = 1'b1;
        trans.is_ctrl = 1'b1;

        `uvm_send(trans);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        trans.print();

        `uvm_info(get_name(), "waiting for the transaction to be finished", UVM_MEDIUM);
        repeat ((`tctrlupd_min + `tctrlupd_max)/2) @(posedge vif.clock);

        `uvm_info(get_name(), "Ending the request", UVM_MEDIUM);        
        trans.req = 1'b0;
        `uvm_send(req);

        `uvm_info(get_name(), "end the transaction", UVM_MEDIUM);
        repeat (10) @(posedge vif.clock);

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass