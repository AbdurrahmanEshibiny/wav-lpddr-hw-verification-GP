class wddr_DFI_all_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_all_seq)

    function new(string name = "wddr_DFI_all_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err, trans_type;
		wav_DFI_lp_transfer trans = new();
        super.body();
        ddr_boot(err);

        init_vif();
        set_dfi_wck_mode(1);

        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        handle_status_internally(); 		
		wait_dfi_cycles(10);

        for (int i = 0; i < 20; ++i) begin
            perform_write_2to1();
            wait_dfi_cycles(10);

            perform_control();
            wait_dfi_cycles(2);
        end
        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass