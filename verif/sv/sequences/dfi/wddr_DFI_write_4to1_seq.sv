class wddr_DFI_write_4to1_seq extends wddr_base_seq;
    `uvm_object_utils(wddr_DFI_write_4to1_seq)

    function new(string name="wddr_DFI_write_4to1_seq");
        super.new(name);
    endfunction

    virtual task body();
        wav_DFI_write_transfer trans = new();
        int err;

        freqRatio = 2;  // to set the frequency to 4:1

        super.body();
        // ddr_boot(err);
        phy_bringup(err);
        set_dfi_wck_mode(1);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(trans);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);
        
        

        // you can determine the transaction values here


        // sendin the transaction
        `uvm_send(trans);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        trans.print();
        
        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask : body

endclass

