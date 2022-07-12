class wddr_DFI_random_write_data_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_random_write_data_seq)

    function new(string name = "wddr_DFI_random_write_data_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err;
        configurations my_config = new();
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        
        my_config.init = 1;
        for (int i = 0; i < 50; ++i) begin
            assert(my_config.randomize());
            random_configuration(my_config);
            wait_dfi_cycles(10);

            perform_random_write_data();
            my_config.init = 0;
            wait_dfi_cycles(10);
        end
    endtask

endclass