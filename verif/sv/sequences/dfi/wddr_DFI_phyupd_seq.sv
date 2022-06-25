class wddr_DFI_phyupd_seq extends wddr_base_seq;

    function new(string name="wddr_DFI_phyupd_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_phyupd_seq)

    virtual task body();
        `uvm_info(get_name(), $sformatf("DFI sequence started!!!!!!!!"),UVM_LOW);
        super.body();
        `uvm_info(get_name(), $sformatf("super.body() finished"),UVM_LOW);
        fork
            EventHandler::wait_for_transaction(EventHandler::phyupd);
            t_dfi_phyupd(err_cnt);
        join
        if ( err_cnt != 0 ) 
            `uvm_error(get_name(), $sformatf("Task t_dfi_phyupd err_cnt = %d ", err_cnt));

        `uvm_info(get_name(), $sformatf("DFI sequence completed!!!!!!!!"),UVM_LOW);
    endtask : body

endclass