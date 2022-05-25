class wddr_DFI_write_seq extends wddr_base_seq;

    function new(string name="wddr_DFI_write_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_write_seq)

    virtual task body();
        wav_DFI_write_transfer trans = new();
        int err;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end
        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(trans);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);
        #4;
        trans.wck_en[0]=1;
        trans.wck_en[1]=1;
        trans.wck_en[2]=1;
        trans.wck_en[3]=1;
        trans.wck_toggle[0]=2'b10;
        trans.wck_toggle[1]=2'b10;
        trans.wck_toggle[2]=2'b10;
        trans.wck_toggle[3]=2'b10;
        trans.wrdata_en[0]=1;
        trans.wrdata_en[1]=1;
        trans.wrdata_en[2]=1;
        trans.wrdata_en[3]=1;

        //trans.randomize();
        `uvm_send(trans);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        trans.print();

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask : body

endclass

