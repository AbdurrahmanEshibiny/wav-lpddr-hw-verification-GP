class wddr_DFI_several_control_seq extends wddr_base_seq;

    `uvm_object_utils(wddr_DFI_several_control_seq)

    function new(string name = "wddr_DFI_several_control_seq");
        super.new(name);  
    endfunction

    virtual task body();
        int err, trans_type;
		wav_DFI_lp_transfer trans = new();
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt = %d ", err_cnt));
        end

        handle_status_internally(); 
		
		trans.req = 0;
		trans.is_rsp_required = 0;
		trans.cyclesCount = 1;
		trans.is_ctrl = 1;
		trans.wakeup[5] = 1;
		`uvm_send(trans);
		trans.is_ctrl = 0;
		`uvm_send(trans);
		
		wait_dfi_cycles(10);

        for (int i = 0; i < 100; ++i) begin
              trans_type = $urandom_range(0, 5);
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
                    // get_response(rsp); 
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
                    // get_response(rsp); 
                end

                2: begin
                    `uvm_info(get_name(), "Sending a phymstr transaction", UVM_MEDIUM);
                    t_dfi_phymstr(err_cnt, 1'b0);
                end

                3: begin
                    `uvm_info(get_name(), "Sending a phyupd transaction", UVM_MEDIUM);
                    t_dfi_phyupd(err_cnt, 1'b0);
                end

                4: begin
                    wav_DFI_update_transfer trans = new();
                    `uvm_info(get_name(), "Sending a ctrlupd transaction", UVM_MEDIUM);
                    trans.req = 1'b1;
                    trans.is_ctrl = 1'b1;
                    `uvm_rand_send(trans);
                    EventHandler::wait_for_transaction(EventHandler::ctrlupd);
                    // get_response(rsp);
                end

                5: begin
                    wav_DFI_status_transfer trans = wav_DFI_status_transfer::type_id::create("seq_item");
                    assert(trans.randomize());
                    `uvm_send(trans);
                    EventHandler::wait_for_transaction(EventHandler::status);
                    // get_response(rsp);
                end
              endcase
        end

        `uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass