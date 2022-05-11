class wddr_DFI_phyupd_seq extends wddr_base_seq;

    function new(string name="wddr_DFI_phyupd_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_phyupd_seq)

    virtual task body();
        super.body();
        t_dfi_phymstr(err_cnt);
        if ( err_cnt != 0 ) `uvm_error(get_type_name(), $sformatf("Task t_dfi_phymstr err_cnt = %d ", err_cnt));
        `uvm_info(get_type_name(), $sformatf("DFI sequence completed!!!!!!!!"),UVM_LOW)
    endtask : body

endclass