class wav_DFI_agent extends uvm_agent;
  
    `uvm_component_utils(wav_DFI_agent)
  
    wav_DFI_driver driver;
    wav_DFI_sequencer sequencer;
    wav_DFI_monitor monitor;
    wav_DFI_vif vif;
  
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = wav_DFI_monitor::type_id::create("wav_DFI_monitor", this);
        sequencer = wav_DFI_sequencer::type_id::create("wav_DFI_sequencer", this);
        driver = wav_DFI_driver::type_id::create("wav_DFI_driver", this);

        `uvm_info(get_type_name(), $psprintf("DFI Agent subcomponenets are built"), UVM_MEDIUM);

        `uvm_info(get_name(), "Setting the DFI sequencer into the db", UVM_MEDIUM);                
        uvm_config_db#(wav_DFI_sequencer)::set(uvm_root::get(), "*", "DFI_sequencer", sequencer);
        
        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
        monitor.vif = vif;
        driver.vif = vif;

        `uvm_info(get_type_name(), $psprintf("DFI Agent subcomponenets have their virtual interfaces connected"), UVM_MEDIUM);
    endfunction
  
    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        `uvm_info(get_type_name(), "DFI Agent's driver's port is connected the sequencer's", UVM_MEDIUM);
    endfunction
  
  endclass