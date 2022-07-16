`ifndef _DFI_CA_RAND_TEST_
`define _DFI_CA_RAND_TEST_

class dfi_ca_rand_test extends wddr_base_test;

    `uvm_component_utils(dfi_ca_rand_test)

    function new (string name = "dfi_ca_rand_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction:new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
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
        ca_rand_seq dfi_seq;

        `uvm_info (
            get_name(),
            $psprintf("Running DFI CA RANDOM TEST"), UVM_LOW
        )
        phase.raise_objection(this, "start_test");

        super.run_phase(phase);

        if (!uvm_config_db#(wav_DFI_sequencer)::get(uvm_root::get(), "*", "DFI_sequencer", sequencer))
            `uvm_fatal(get_name(), "Failed at getting the sequencer")
        dfi_seq = ca_rand_seq::type_id::create("dfi_seq");
        dfi_seq.start(sequencer);
        phase.drop_objection(this,"Done test.");

    endtask

endclass

`endif