class wddr_DFI_write_seq extends wddr_base_seq;
    `uvm_object_utils(wddr_DFI_write_seq)

    function new(string name="wddr_DFI_write_seq");
        super.new(name);
    endfunction

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
        trans.wrdata[0]=64'hffffaaaa11112222;
        trans.wrdata[1]=64'hffffaaaa11112222;
        trans.wrdata[2]=64'hffffaaaa11112222;
        trans.wrdata[3]=64'hffffaaaa11112222;
        trans.address[0]=14'b10101010101010;
        trans.address[1]=14'b10101010101010;
        trans.address[2]=14'b10101010101010;
        trans.address[3]=14'b10101010101010;
        trans.dram_clk_disable[0]=0;
        trans.dram_clk_disable[1]=0;
        trans.dram_clk_disable[2]=0;
        trans.dram_clk_disable[3]=0;
        trans.wck_en[0]=1;
        trans.wck_en[1]=1;
        trans.wck_en[2]=1;
        trans.wck_en[3]=1;
        trans.wck_toggle[0]=2'b00;
        trans.wck_toggle[1]=2'b01;
        trans.wck_toggle[2]=2'b10;
        trans.wck_toggle[3]=2'b11;
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

