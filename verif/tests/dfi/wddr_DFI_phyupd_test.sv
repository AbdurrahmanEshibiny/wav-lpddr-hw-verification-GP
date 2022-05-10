`ifndef WDDR_DFI_PHYUPD_TEST
`define WDDR_DFI_PHYUPD_TEST

class wddr_DFI_phyupd_test extends wddr_base_test;

    `uvm_component_utils(wddr_DFI_phyupd_test)

    function new (string name = "wddr_DFI_phyupd_test", uvm_component parent=null);
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

        wddr_DFI_phyupd_seq  dfi_seq;

        `uvm_info (get_type_name(),$psprintf("------- Running WDDR DFI PHYMSTR TEST ---------"),UVM_LOW)
        phase.raise_objection(this, "start_test");

        super.run_phase(phase);

        dfi_seq = wddr_DFI_phyupd_seq::type_id::create("dfi_seq");

        dfi_seq.start(null);

        phase.drop_objection(this,"Done test.");

    endtask

endclass

`endif
