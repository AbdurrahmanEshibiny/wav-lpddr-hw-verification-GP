class wav_DFI_monitor extends uvm_monitor;

    wav_DFI_vif vif;

    uvm_analysis_port #( wav_DFI_transfer) item_collected_port; 

    const int wakeup_times[20] = '{1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,-1};
    const int phyupd_types[4] = '{`tphyupd_type0, `tphyupd_type1, `tphyupd_type2, `tphyupd_type3};
    const int phymstr_types[4] = '{`tphymstr_type0, `tphymstr_type1, `tphymstr_type2, `tphymstr_type3};

    `uvm_component_utils_begin(wav_DFI_monitor)
    `uvm_component_utils_end

    function new (string name = "wav_DFI_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
	/*add collect for remaining interface signals*/
    //each task samples a single packet from the corresponding sub-interface 
    task collect_lp_ctrl(ref wav_DFI_lp_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.lp_ctrl_req; 
        trans.ack = vif.mp_mon.cb_mon.lp_ctrl_ack; 
        trans.wakeup = vif.mp_mon.cb_mon.lp_ctrl_wakeup; 
        trans.is_ctrl = 1; 
    endtask
          
    task collect_lp_data(ref wav_DFI_lp_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.lp_data_req; 
        trans.ack = vif.mp_mon.cb_mon.lp_data_ack; 
        trans.wakeup = vif.mp_mon.cb_mon.lp_data_wakeup; 
        trans.is_ctrl = 0; 
    endtask    
          
    task collect_phymstr(ref wav_DFI_phymstr_transfer trans);     
        trans.req = vif.mp_mon.cb_mon.phymstr_req; 
        trans.ack = vif.mp_mon.cb_mon.phymstr_ack; 
        trans._type = vif.mp_mon.cb_mon.phymstr_type; 
        trans.state_sel = vif.mp_mon.cb_mon.phymstr_state_sel;     
        trans.cs_state = vif.mp_mon.cb_mon.phymstr_cs_state; 
    endtask  
          
    task collect_phyupd(ref wav_DFI_update_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.phyupd_req; 
        trans.ack = vif.mp_mon.cb_mon.phyupd_ack; 
        trans._type = vif.mp_mon.cb_mon.phyupd_type; 
    endtask
    
    task collect_ctrlupd(ref wav_DFI_update_transfer trans); 
        trans.req = vif.mp_mon.cb_mon.ctrlupd_req; 
        trans.ack = vif.mp_mon.cb_mon.ctrlupd_ack; 
    endtask

/* add handles for the remaining interface signals*/
    //Handles a single request and performs any required checking throughout the transaction
    task handle_lp(bit is_ctrl);
        wav_DFI_lp_transfer trans;
        int wakeup = -1;
        int counter = 0, steadyCounter = 0;
        bit isAcked = 0;
        trans = new();
        forever begin
            if (is_ctrl) collect_lp_ctrl(trans); else collect_lp_data(trans);
            if (trans.req) begin
                if (wakeup > trans.wakeup) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been DECREASED from %0d to %0d", wakeup, trans.wakeup));
                end
                else if ((wakeup != trans.wakeup) && !trans.ack) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been changed from %0d to %0d while ack was not high", wakeup, trans.wakeup));
                end
                else if ((wakeup != trans.wakeup) && steadyCounter < `tlp_resp) begin
                    `uvm_error(get_name(), $psprintf("wakeup time has been changed from %0d to %0d so early in %0d cycles", wakeup, trans.wakeup, steadyCounter));
                end
                else begin
                    `uvm_info(get_name(), $psprintf("wakeup time has been INCREASED from %0d to %0d", wakeup, trans.wakeup), UVM_MEDIUM);                    
                    wakeup = trans.wakeup;
                end
                ++steadyCounter;
            end
            else if (trans.ack) begin
                if (steadyCounter < `tlp_resp && !isAcked) begin
                    `uvm_error(get_name(), $psprintf("lp req has been activated only for %0d instead of %0d", steadyCounter, `tlp_resp));
                end
                isAcked = 1;
                ++counter;
            end
            else 
                break;
            @(vif.mp_mon.cb_mon);
        end

        if (wakeup != 19 && counter > wakeup_times[wakeup]) begin
            `uvm_error(get_name(), $psprintf("PHY stayed asleep more than the wakeup time, it should stay %d, but it stayed %d", wakeup_times[wakeup], counter));
        end
    endtask

    task handle_phyupd();
        wav_DFI_update_transfer trans, original;
        int counter = 0, steadyCounter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phyupd(original);
        forever begin
            collect_phyupd(trans);
            if (trans.req) begin
                ++steadyCounter;
                if (trans.ack)
                    count = 1'b1;
            end
            else begin
                if (steadyCounter > `tphyupd_resp) begin
                    `uvm_error(get_name(), $psprintf("phyupd req stayed high for %0d more than %0d", steadyCounter, `tphyupd_resp));
                end

                if (!trans.ack) begin
                    if (counter > phyupd_types[original._type]) begin
                        `uvm_error(get_name(), $psprintf("phyupd req stayed high for %0d more than %0d", counter, phyupd_types[original._type]));
                    end 
                    else begin
                        `uvm_info(get_name(), $psprintf("phyupd_req stayed HIGH for %d", counter), UVM_MEDIUM);
                    end
                    break;
                end
                else begin
                    if (next_should_be_idle) begin
                        `uvm_error(get_name(), "phyupd_ack stayed HIGH for more than 1 cycle after phyupd_req became LOW"); 
                    end
                    else
                        next_should_be_idle = 1'b1;
                end
                
            end

            if (count & trans.req)
                ++counter;

            if (original.compare(trans)) begin  // type should be constant
                `uvm_error(get_name(), $psprintf("phyupd type is not stable but changed from %0d to %0d", original._type, trans._type));
            end

            @(vif.mp_mon.cb_mon);
        end
    endtask

    task handle_ctrlupd();
        wav_DFI_update_transfer trans;
        int counter = 0, steadyCounter = 0;
        bit isAcked = 0;
        forever begin
            collect_ctrlupd(trans);
            if (trans.req) begin
                ++steadyCounter;
            end
            else begin
                // For how many cycles was ctrlupd req stable ?
                if (steadyCounter < `tctrlupd_min) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req stayed high for only %0d instead of %0d", steadyCounter, `tctrlupd_min));
                end
                else if (steadyCounter > `tctrlupd_max) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req stayed high for %0d more than %0d", steadyCounter, `tctrlupd_max));
                end
                else begin
                    `uvm_info(get_name(), $psprintf("ctrlupd req stayed high for only %0d", steadyCounter), UVM_MEDIUM);                    
                end

                if (trans.ack) begin
                    `uvm_error(get_name(), "ctrlupd_req is LOW while ctrlupd_ack is HIGH");
                end
                `uvm_info(get_name(), $psprintf("ctrlupd_ack stayed HIGH for %d", counter), UVM_MEDIUM);
                break;
            end

            if (trans.ack) begin
                if (~isAcked & steadyCounter > `tctrlupd_min) begin
                    `uvm_error(get_name(), $psprintf("ctrlupd req is acked at %0d more than %0d", steadyCounter, `tctrlupd_min));
                end
                ++counter;
                isAcked = 1;
            end

            @(vif.mp_mon.cb_mon);
        end
    endtask

    task handle_phymstr();
        wav_DFI_phymstr_transfer trans, original;
        int counter = 0, steadyCounter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phymstr(original);
        forever begin
            collect_phymstr(trans);
            if (trans.req) begin
                if (trans.ack)
                    count = 1'b1;
                else
                    ++steadyCounter;
            end
            else begin
                if (!trans.ack) begin
                    if (counter > phymstr_types[original._type]) begin
                        `uvm_error(get_name(), $psprintf("phymstr req is asserted in %0d instead of %0d", counter, phymstr_types[original._type]));
                    end
                    else begin
                        `uvm_info(get_name(), $psprintf("phymstr_req stayed HIGH for %d", counter), UVM_MEDIUM);
                    end 
                    break;
                end
                else begin
                    if (next_should_be_idle) begin
                        `uvm_error(get_name(), "phymstr_ack stayed HIGH for more than 1 cycle after phymstr_req became LOW"); 
                    end
                    else
                        next_should_be_idle = 1'b1;
                end
            end

            if (count & trans.req)
                ++counter;

            if (original.compare(trans)) begin
                `uvm_error(get_name(), "Some of the phymstr signals are not the stable during the transaction");
            end

            @(vif.mp_mon.cb_mon);
        end
    endtask
/*add monitor functions to the remaining interface signals*/
    //each task goes in a forever loop that monitors a specific sub-interface, collects 
    //a packet whenever it detects a change, and then it write the packet in the analysis 
    //port for the scoreboard to perform its checks 
    task monitor_lp_ctrl(); 
        forever begin 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_ctrl_req) begin
                `uvm_info(get_name(), "lp_ctrl transaction is detected", UVM_MEDIUM);                
                handle_lp(1);
            end
        end      
    endtask          
        
    task monitor_lp_data();         
        forever begin                 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_data_req) begin
                `uvm_info(get_name(), "lp_data transaction is detected", UVM_MEDIUM);
                handle_lp(0);
            end
        end
    endtask

    task monitor_phyupd ();           
        forever begin                
            @(vif.mp_mon.cb_mon)     
            if (vif.mp_mon.cb_mon.phyupd_req) begin
                `uvm_info(get_name(), "phyupd transaction is detected", UVM_MEDIUM);
                handle_phyupd();  
            end
        end     
    endtask
    
    task monitor_ctrlupd ();                 
        forever begin            
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.ctrlupd_req) begin
                `uvm_info(get_name(), "ctrlupd transaction is detected", UVM_MEDIUM);
                handle_ctrlupd();
            end
        end 
    endtask  
    
    task monitor_phymstr();                 
        forever begin         
            @(vif.mp_mon.cb_mon)       
            if (vif.mp_mon.cb_mon.phymstr_req) begin
                `uvm_info(get_name(), "phymstr transaction is detected", UVM_MEDIUM);
                handle_phymstr();
            end
        end    
    endtask

    task monitor_initiailization();
        wav_DFI_lp_transfer lp_ctrl = new(), lp_data = new();
        wav_DFI_phymstr_transfer phymstr = new();
        wav_DFI_update_transfer ctrlupd = new(), phyupd = new();

        @(vif.mp_mon.cb_mon) 
        // Collect initial transaction at the first cycle
        collect_ctrlupd(ctrlupd);
        collect_phyupd(phyupd);
        collect_lp_ctrl(lp_ctrl);
        collect_lp_data(lp_data);
        collect_phymstr(phymstr);

        if (ctrlupd.req || ctrlupd.ack) begin
            `uvm_error(get_name(), "ctrlupd interface is not zero at initialization");
            ctrlupd.print();
        end

        if (phyupd.req || phyupd.ack || phyupd._type) begin
            `uvm_error(get_name(), "phyupd interface is not zero at initialization");
            phyupd.print();
        end

        if (phymstr.req || phymstr.ack || phymstr._type || phymstr.state_sel || phymstr.cs_state) begin
            `uvm_error(get_name(), "phymstr interface is not zero at initialization");
            phyupd.print();
        end

        if (lp_ctrl.req || lp_ctrl.ack || lp_ctrl.wakeup) begin
            `uvm_error(get_name(), "lp_ctrl interface is not zero at initialization");
            lp_ctrl.print();
        end

        if (lp_data.req || lp_data.ack || lp_data.wakeup) begin
            `uvm_error(get_name(), "lp_data interface is not zero at initialization");
            lp_data.print();
        end

    endtask

    //A task to call all the monitoring tasks created earlier to work in parallel 
    task collect_transfers(); 
        fork      
            monitor_initiailization();  
            monitor_phymstr();         
            monitor_lp_ctrl();         
            monitor_lp_data();         
            monitor_phyupd();         
            monitor_ctrlupd();
/*add monitor function to the remaining interface signals*/       
        join_none
    endtask
endclass