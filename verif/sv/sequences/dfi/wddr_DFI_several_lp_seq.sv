class wddr_DFI_several_lp_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_several_lp_seq)

    function new(string name = "wddr_DFI_several_lp_seq");
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

        for (int i = 0; i < 30; ++i) begin
            `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
            `uvm_create(trans);
            `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

            trans.req = 1'b1;
            trans.is_ctrl = $urandom_range(0, 1);
            assert(trans.randomize() with {wakeup > 1;});
            `uvm_send(trans);

            `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

            `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
            trans.print();
            if (trans.is_ctrl)
                EventHandler::wait_for_transaction(EventHandler::lp_ctrl);
            else
                EventHandler::wait_for_transaction(EventHandler::lp_data);
            // get_response(rsp);   
        end

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass