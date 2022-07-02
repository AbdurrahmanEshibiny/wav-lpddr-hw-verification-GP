class wddr_DFI_access_control_regs_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_access_control_regs_seq)

    function new(string name = "wddr_DFI_access_control_regs_seq");
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

        // read_only_addresses = {'h10, 'h20, 'h30, 'h40, 'h50, 'h58};
        addresses = {0, 4, 8, 'h14, 'h18, 'h24, 'h28, 'h34, 'h38, 'h44, 'h48, 'h5c};

        wrdata = 0;
        rddata = 0;
        // for (int i = 0; i <= 'h5c; i += 4) begin
        foreach (addresses[i]) begin
            bit [31:0] address = addresses[i];
            // temp = read_only_addresses.find() with (item == i);
            // if (temp.size() != 0)
            //     continue;

            wrdata = 0;
            for (int j = 0; j < 3; ++j) begin
                rddata = 0;
                csr_write(DDR_DFI_OFFSET, address, wrdata);
                csr_read(DDR_DFI_OFFSET, address, rddata);
                if (wrdata != 0 && 0 == rddata) begin
                    `uvm_error(get_name(), $psprintf("Address of offset %0h cannot be written and read correctly. wrdata=%0h rddata=%0h", i, wrdata, rddata));                
                end else begin
                    `uvm_info(get_name(),  $psprintf("Address of offset %0h is be written and read correctly. wrdata=%0h rddata=%0h", i, wrdata, rddata), UVM_MEDIUM);                    
                end
                wrdata = ~wrdata;
            end
        end
    endtask

endclass