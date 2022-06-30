class wddr_DFI_several_control_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_several_control_seq)

    function new(string name = "wddr_DFI_several_control_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err, trans_type;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        for (int i = 0; i < 30; ++i) begin
              trans_type = $urandom_range(0, 3);
              `uvm_info(get_name(), $psprintf("Starting the %0d transaction", i), UVM_MEDIUM);
              case (trans_type)
                0:  begin                   
                    wav_DFI_lp_transfer trans = new();
                    `uvm_info(get_name(), "Sending a lp_ctrl transaction", UVM_MEDIUM); 
                    `uvm_create(trans);
                    trans.req = 1'b1;
                    trans.is_ctrl = 1'b1;
                    `uvm_rand_send(trans);
                    trans.print();
                    EventHandler::wait_for_transaction(EventHandler::lp_ctrl);
                    get_response(rsp); 
                end

                1: begin                    
                    wav_DFI_lp_transfer trans = new();
                    `uvm_info(get_name(), "Sending a lp_data transaction", UVM_MEDIUM);
                    `uvm_create(trans);
                    trans.req = 1'b1;
                    trans.is_ctrl = 1'b0;
                    `uvm_rand_send(trans);
                    trans.print();
                    EventHandler::wait_for_transaction(EventHandler::lp_data);
                    get_response(rsp); 
                end

                2: begin
                    `uvm_info(get_name(), "Sending a phymstr transaction", UVM_MEDIUM);
                    t_dfi_phymstr(err_cnt, 1'b0);
                end

                3: begin
                    `uvm_info(get_name(), "Sending a phyupd transaction", UVM_MEDIUM);
                    t_dfi_phyupd(err_cnt, 1'b0);
                end
              endcase
        end

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass