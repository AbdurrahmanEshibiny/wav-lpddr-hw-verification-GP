class wddr_DFI_write_4to1_seq extends wddr_base_seq;
    `uvm_object_utils(wddr_DFI_write_4to1_seq)

    function new(string name="wddr_DFI_write_4to1_seq");
        super.new(name);
        freqRatio = 2;  // to set the frequency to 4:1
    endfunction

    virtual task body();
        wav_DFI_write_transfer trans = new();
        int err;

        super.body();
        ddr_boot(err);
        init_vif();
        set_dfi_wck_mode(1);
        set_freq_ratio(4);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        `uvm_info(get_type_name(), $psprintf("1.PRE-CREATE OF TRANSACTION"), UVM_LOW);
        `uvm_create(trans);
        `uvm_info(get_type_name(), $psprintf("2.POST-CREATE, PRE-RUN OF TRANSACTION"), UVM_LOW);

        @(posedge vif.mp_drv.cb_drv);
            //ck_c ck_t dram clock enable 
            trans.dram_clk_disable[0] = 0;
            trans.dram_clk_disable[1] = 0;
            trans.dram_clk_disable[2] = 0;
            trans.dram_clk_disable[3] = 0;
            //wck initialized to static mood
            trans.wck_cs[0] = 2'b01;
            trans.wck_cs[1] = 2'b01;
            trans.wck_cs[2] = 2'b01;
            trans.wck_cs[3] = 2'b01;

            trans.wck_en[0] = 1;
            trans.wck_en[1] = 1;
            trans.wck_en[2] = 1;
            trans.wck_en[3] = 1;
            //static low
            trans.wck_toggle[0] = 2'b00;
            trans.wck_toggle[1] = 2'b00;
            trans.wck_toggle[2] = 2'b00;
            trans.wck_toggle[3] = 2'b00;

             //enable ca dram bus
            trans.cke[0] = 2'b01;
            trans.cke[1] = 2'b01;
            trans.cke[2] = 2'b00;
            trans.cke[3] = 2'b00;

        `uvm_send(trans);
        @(posedge vif.mp_drv.cb_drv);
            trans.cs[0] = 2'b01;
            trans.cs[1] = 2'b01;
            trans.cs[2] = 2'b00;
            trans.cs[3] = 2'b00;
        
        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv);
        @(posedge vif.mp_drv.cb_drv);
        @(posedge vif.mp_drv.cb_drv);
            //toggle
            trans.wck_toggle[0] = 2'b10;
            trans.wck_toggle[1] = 2'b01;
            trans.wck_toggle[2] = 2'b00;
            trans.wck_toggle[3] = 2'b00;

        `uvm_send(trans);

       
           
        
        

        @(posedge vif.mp_drv.cb_drv);
            //ACT1
            trans.address[0] = 14'b0000000_0000111;
            trans.address[1] = 14'b0000000_0000000;

            trans.cs[0] = 2'b00;
            trans.cs[1] = 2'b00;
            trans.cs[2] = 2'b00;
            trans.cs[3] = 2'b00;

        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv);
            //ACT2
            trans.address[0] = 14'b0000000_0000011;
            trans.address[1] = 14'b0000000_0000000;
        
        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv);
            //CAS_WR
            trans.address[0] = 14'b0000000_0011100;
            trans.address[1] = 14'b0000000_0000000;

        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv);
            //WR16
            trans.address[0] = 14'b0000000_0000100;
            trans.address[1] = 14'b0000000_1000000;
            // fast toggle 
            trans.wck_toggle[0] = 2'b11;
            trans.wck_toggle[1] = 2'b11;
            trans.wck_toggle[2] = 2'b11;
            trans.wck_toggle[3] = 2'b11;
    
        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv);      
            trans.address[0] = 14'b0000000_0000000;
            trans.address[1] = 14'b0000000_0000000;
            //finish of the commands before read (ACT1-ACT2-CASWR-WR16)
         `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv); 
            //data
            trans.wrdata[0] = 64'h1234_ffff_5678_ffff; 
            trans.wrdata[1] = 64'habcd_0000_ef98_0000;
            trans.wrdata[2] = 64'hzzzz_zzzz_zzzz_zzzz; 
            trans.wrdata[3] = 64'hzzzz_zzzz_zzzz_zzzz;
        

        `uvm_send(trans);

        /**************************** delay Tphy_wrdata between wrdata and wrdata_en ********************/
        /**************************** delay Tphy_wrdata between wr16 command and wrdata_en ********************/
        
        @(posedge vif.mp_drv.cb_drv); 
            //wrdata enable 
            trans.wrdata_en[0] = 0;
            trans.wrdata_en[1] = 1;
            trans.wrdata_en[2] = 0;
            trans.wrdata_en[3] = 0;
            trans.wrdata_cs[0] = 2'b01;
            trans.wrdata_cs[1] = 2'b01;
            trans.wrdata_cs[2] = 2'b01;
            trans.wrdata_cs[3] = 2'b01;

        `uvm_send(trans);

            
        @(posedge vif.mp_drv.cb_drv);
            trans.wrdata_en[0] = 0;
            trans.wrdata_en[1] = 0;
            trans.wrdata_en[2] = 0;
            trans.wrdata_en[3] = 0;
            
        `uvm_send(trans);

        @(posedge vif.mp_drv.cb_drv); 
        @(posedge vif.mp_drv.cb_drv);  
        @(posedge vif.mp_drv.cb_drv); 
        @(posedge vif.mp_drv.cb_drv); 
        @(posedge vif.mp_drv.cb_drv); 
        @(posedge vif.mp_drv.cb_drv);  
        @(posedge vif.mp_drv.cb_drv); 
        @(posedge vif.mp_drv.cb_drv);      
        @(posedge vif.mp_drv.cb_drv);
            //ending the write transaction 
            trans.wrdata_cs[0] = 2'b00;
            trans.wrdata_cs[1] = 2'b00;
            trans.wrdata_cs[2] = 2'b00;
            trans.wrdata_cs[3] = 2'b00;
            trans.wrdata[0] = 64'hzzzz_zzzz_zzzz_zzzz;
            trans.wrdata[1] = 64'hzzzz_zzzz_zzzz_zzzz;
            trans.wrdata[2] = 64'hzzzz_zzzz_zzzz_zzzz;
            trans.wrdata[3] = 64'hzzzz_zzzz_zzzz_zzzz;
            
            //static        
            trans.wck_toggle[0] = 2'b00;
            trans.wck_toggle[1] = 2'b00;
            trans.wck_toggle[2] = 2'b00;
            trans.wck_toggle[3] = 2'b00;
            
        // sendin the transaction
        `uvm_send(trans);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        trans.print();
        
        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask : body

endclass

