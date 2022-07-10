/*********************************************************************************
Copyright (c) 2021 Wavious LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************************/
class wddr_tb extends uvm_env;

    `uvm_component_utils(wddr_tb)

    wav_APB_agent                apb_agent;
    wav_DFI_agent                dfi_agent;
    gp_LPDDR5_agent              lpddr5_agent;
    wddr_reg_model               reg_model;

    wddr_subscriber              subscriber;
    //wddr_scoreboard              scoreboard;
    //RAL declartions
    reg_to_apb_adapter                   reg2apb;
    uvm_reg_predictor#(wav_APB_transfer) apb_predictor;

    //---Constructor for wav_chip_tb
    function new (string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction

    //---Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        apb_agent        = wav_APB_agent::type_id::create("apb_agent", this);
        lpddr5_agent     = gp_LPDDR5_agent::type_id::create("lpddr5_agent", this);
        dfi_agent        = wav_DFI_agent::type_id::create("dfi_agent", this);
        reg2apb          = reg_to_apb_adapter::type_id::create("reg2apb");

        //scoreboard       = wddr_scoreboard::type_id::create("scoreboard", this);
        subscriber       = wddr_subscriber::type_id::create("subscriber", this);
        // Predictor
        apb_predictor    = uvm_reg_predictor#(wav_APB_transfer)::type_id::create("apb_predictor", this);

        //Create Regmodel
        if(reg_model==null) begin
            `uvm_info(get_type_name(), $psprintf("Building Reg Model "), UVM_NONE);
            reg_model = wddr_reg_model::type_id::create("reg_model", this);
            reg_model.build();
            reg_model.lock_model();
        end

        //Set the regmodel for rest of the testbench
        uvm_config_object::set(this, "*", "reg_model", reg_model);

    endfunction

    //---Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        apb_predictor.map     = reg_model.MAP_APB;
        apb_predictor.adapter = reg2apb;
        reg_model.MAP_APB.set_sequencer(.sequencer(apb_agent.sequencer), .adapter(reg2apb));
        reg_model.MAP_APB.set_auto_predict(0);
        reg_model.add_hdl_path("wddr_tb_top");
        apb_agent.monitor.item_collected_port.connect(apb_predictor.bus_in);

        // Set the regmodel for rest of the testbench
        uvm_config_object::set(uvm_root::get(), "*", "reg_model", reg_model);
        uvm_config_object::set(uvm_root::get(), "*", "reg_map"  , reg_model.MAP_APB); //TBD Check the MAP name

        // Connect the LPDDR5 monitor to the subscriber
        lpddr5_agent.lpddr5_monitor.subscriber_port_item.connect(subscriber.LPDDR5_imp);
        // Connect the DFI monitor to the subscriber
        dfi_agent.monitor.subscriber_port_item.connect(subscriber.DFI_imp);

        // connecting scoreboard to DFI
        //dfi_agent.driver.seq_item_port.connect(scoreboard.seq_item_export);

        // connecting scoreboard to LPDDR5
        //lpddr5_agent.lpddr5_monitor.recieved_transaction.connect(scoreboard.fifo_recieved.analysis_export);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        //this.print();
    endfunction : end_of_elaboration_phase

    //---RUN Phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass // wddr_tb
