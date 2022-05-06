class wav_DFI_monitor extends uvm_monitor;

    virtual wav_DFI_if vif;

    uvm_analysis_port #( wav_DFI_transfer) item_collected_port; 

    const int wakeup_times[20] = '{1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,-1};

    `uvm_component_utils_begin(wav_DFI_monitor)
    `uvm_component_utils_end

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

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


    //Handles a single request and performs any required checking throughout the transaction
    task handle_lp_ctrl();
        wav_DFI_lp_transfer trans;
        int wakeup = -1;
        int counter = 0;
        trans = new();
        forever begin
            collect_lp_ctrl(trans);
            if (trans.req)
                wakeup = trans.wakeup;
            else if (trans.ack)
                ++counter;
            else 
                break;
            @(vif.mp_mon.cb_mon);
        end

        if (wakeup != 19 && counter > wakeup_times[wakeup]) begin
            `uvm_error(get_name(), $psprintf("PHY stayed asleep more than the wakeup time, it should stay %d, but it stayed %d", wakeup_times[wakeup], counter));
        end
    endtask

    task handle_lp_data();
        wav_DFI_lp_transfer trans;
        int wakeup = -1;
        int counter = 0;
        trans = new();
        forever begin
            collect_lp_data(trans);
            if (trans.req)
                wakeup = trans.wakeup;
            else if (trans.ack)
                ++counter;
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
        int counter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phyupd(original);
        forever begin
            collect_phyupd(trans);
            if (!trans.req & !trans.ack) begin
                `uvm_info(get_name(), $psprintf("phyupd_req stayed HIGH for %d", counter), UVM_MEDIUM);
                break;
            end
            else if (!trans.req & trans.ack) begin
                if (next_should_be_idle) begin
                    `uvm_error(get_name(), "phyupd_ack stayed HIGH for more than 1 cycle after phyupd_req became LOW"); 
                end
                else
                    next_should_be_idle = 1'b1;
            end
            else if (trans.req & trans.ack) begin
                count = 1'b1;
            end

            if (count & trans.req)
                ++counter;

            if (original.compare(trans))
                `uvm_error(get_name(), "Some of the phyupd signals are not the stable during the transaction");

            @(vif.mp_mon.cb_mon);
        end
    endtask

    task handle_ctrlupd();
        wav_DFI_update_transfer trans;
        int counter = 0;
        forever begin
            collect_ctrlupd(trans);
            if (!trans.req) begin
                if (trans.ack)
                    `uvm_error(get_name(), "ctrlupd_req is LOW while ctrlupd_ack is HIGH");
                `uvm_info(get_name(), $psprintf("ctrlupd_ack stayed HIGH for %d", counter), UVM_MEDIUM);
                break;
            end
            if (trans.ack) begin
                ++counter;
            end
            @(vif.mp_mon.cb_mon);
        end
    endtask

    task handle_phymstr();
        wav_DFI_phymstr_transfer trans, original;
        int counter = 0;
        bit next_should_be_idle = 0, count = 0;
        trans = new();
        original = new();
        collect_phymstr(original);
        forever begin
            collect_phymstr(trans);
            if (!trans.req & !trans.ack) begin
                `uvm_info(get_name(), $psprintf("phymstr_req stayed HIGH for %d", counter), UVM_MEDIUM);
                break;
            end
            else if (!trans.req & trans.ack) begin
                if (next_should_be_idle) begin
                    `uvm_error(get_name(), "phymstr_ack stayed HIGH for more than 1 cycle after phymstr_req became LOW"); 
                end
                else
                    next_should_be_idle = 1'b1;
            end
            else if (trans.req & trans.ack) begin
                count = 1'b1;
            end

            if (count & trans.req)
                ++counter;

            if (original.compare(trans))
                `uvm_error(get_name(), "Some of the phymstr signals are not the stable during the transaction");

            @(vif.mp_mon.cb_mon);
        end
    endtask

    //each task goes in a forever loop that monitors a specific sub-interface, collects 
    //a packet whenever it detects a change, and then it write the packet in the analysis 
    //port for the scoreboard to perform its checks 
    task monitor_lp_ctrl(); 
        forever begin 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_ctrl_req)
                handle_lp_ctrl();
        end      
    endtask          
        
    task monitor_lp_data();         
        forever begin                 
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.lp_data_req)
                handle_lp_data();
        end
    endtask

    task monitor_phyupd ();           
        forever begin                
            @(vif.mp_mon.cb_mon)     
            if (vif.mp_mon.cb_mon.phyupd_req) 
                handle_phyupd();  
        end     
    endtask
    
    task monitor_ctrlupd ();                 
        forever begin            
            @(vif.mp_mon.cb_mon) 
            if (vif.mp_mon.cb_mon.ctrlupd_req)
                handle_ctrlupd();
        end 
    endtask  
    
    task monitor_phymstr();                 
        forever begin         
            @(vif.mp_mon.cb_mon)       
            if (vif.mp_mon.cb_mon.phymstr_req)
                handle_phymstr();
        end    
    endtask

    //A task to call all the monitoring tasks created earlier to work in parallel 
    task collect_transfers(); 
        fork        
            monitor_phymstr();         
            monitor_lp_ctrl();         
            monitor_lp_data();         
            monitor_phyupd();         
            monitor_ctrlupd();       
        join_none
    endtask
endclass