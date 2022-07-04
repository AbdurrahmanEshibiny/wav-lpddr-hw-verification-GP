class wddr_DFI_control_with_regs_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_control_with_regs_seq)

    function new(string name = "wddr_DFI_control_with_regs_seq");
        super.new(name);  
    endfunction

    virtual task body();
        bit [31:0] rddata, wrdata;
        // int read_only_addresses[$], temp[$];
        int addresses[$];
        int err;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        
        `uvm_info(get_name(), "lp_data with regs", UVM_MEDIUM);
        t_dfi_lp(err, 0, 0);

        `uvm_info(get_name(), "lp_ctrl with regs", UVM_MEDIUM);
        t_dfi_lp(err, 0, 1);

        `uvm_info(get_name(), "ctrlupd with regs", UVM_MEDIUM);
        t_dfi_ctrlupd(err, 0);
    endtask

endclass