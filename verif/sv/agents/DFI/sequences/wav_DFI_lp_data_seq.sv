class wav_DFI_lp_data_seq extends uvm_sequence #(wav_DFI_lp_transfer);

    `uvm_object_utils(wav_DFI_lp_data_seq)

    function new(string name = "wav_DFI_lp_data_seq");
        super.new(name);  
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(req);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

        req.is_ctrl = 0'b1;

        `uvm_rand_send(req);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        req.print();

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass