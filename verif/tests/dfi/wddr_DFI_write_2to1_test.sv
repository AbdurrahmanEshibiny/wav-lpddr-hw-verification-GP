`ifndef WDDR_DFI_WRITE_2TO1_TEST
`define WDDR_DFI_WRITE_2TO1_TEST

class wddr_DFI_write_2to1_test extends wddr_base_test;

    `uvm_component_utils(wddr_DFI_write_2to1_test)
    gp_LPDDR5_agent              lpddr5_agent;
    function new (string name = "wddr_DFI_write_2to1_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(int) :: set(this, "tb.lpddr5_agent.lpddr5_monitor", "ratio", 2);
        uvm_config_db#(int) :: set(this, "tb.scoreboard", "ratio", 2);
    endfunction :build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task run_phase (uvm_phase phase);

        uvm_objection objection;
        wav_DFI_sequencer sequencer;
        wddr_DFI_write_2to1_seq  dfi_seq;

        `uvm_info (get_type_name(),$psprintf("------- Running WDDR DFI WRITE TEST ---------"),UVM_LOW)
        phase.raise_objection(this, "start_test");

        super.run_phase(phase);

        if (!uvm_config_db#(wav_DFI_sequencer)::get(uvm_root::get(), "*", "DFI_sequencer", sequencer))
            `uvm_fatal(get_name(), "Failed at getting the sequencer");
        dfi_seq = wddr_DFI_write_2to1_seq::type_id::create("dfi_seq");

        dfi_seq.start(sequencer);

        phase.drop_objection(this,"Done test.");

    endtask

endclass

`endif