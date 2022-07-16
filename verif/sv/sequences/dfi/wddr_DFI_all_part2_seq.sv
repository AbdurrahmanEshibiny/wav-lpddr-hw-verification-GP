class wddr_DFI_all_part2_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_all_part2_seq)

    function new(string name = "wddr_DFI_all_part2_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err;
        super.body();
        ddr_boot(err);

        init_vif();
        set_dfi_wck_mode(1);

        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        handle_status_internally(); 		
        wait_dfi_cycles(10);
        
        t_dfi_phyupd(err_cnt, 1'b0);
        wait_dfi_cycles(10);

        perform_read(1);
        wait_dfi_cycles(60);
		perform_read(0);
        wait_dfi_cycles(60);
		
		perform_write_2to1;
        wait_dfi_cycles(60);

        for (int i = 0; i < 20; ++i) begin
            perform_read(0);
            wait_dfi_cycles(60);

            perform_control(1);
            wait_dfi_cycles(20);
        end

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass