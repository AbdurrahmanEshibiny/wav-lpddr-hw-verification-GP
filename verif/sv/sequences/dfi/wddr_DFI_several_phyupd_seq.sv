class wddr_DFI_several_phyupd_seq extends wddr_base_seq;

    function new(string name="wddr_DFI_several_phyupd_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_several_phyupd_seq)

    virtual task body();
		`uvm_info(get_name(), $sformatf("DFI sequence started!!!!!!!!"),UVM_LOW);
        super.body();
        `uvm_info(get_name(), $sformatf("super.body() finished"),UVM_LOW);

        for (int i = 0; i < 10; ++i) begin
            fork 
                t_dfi_phyupd(err_cnt, i==0);
                EventHandler::wait_for_transaction(EventHandler::phyupd);
            join
            
            if ( err_cnt != 0 ) 
                `uvm_error(get_type_name(), $sformatf("Task t_dfi_phyupd err_cnt = %d ", err_cnt));
        end
				
        `uvm_info(get_type_name(), $sformatf("DFI sequence completed!!!!!!!!"),UVM_LOW)
    endtask : body

endclass