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

import uvm_pkg::*;

class wddr_base_seq extends uvm_sequence;

    `uvm_object_utils(wddr_base_seq)

    wddr_reg_model reg_model;
    //cdnDfimcUvmUserSequence trans;

    uvm_status_e  status;
    uvm_reg       regstr;
    string        reg_name;

    reg [31:0]    VAL;
    int  cs;

    string REG_PREFIX;
    string REG_INFIX;
    string SS_INFIX="";
    string SER_SEL="";
    string LANE_NUM="0";
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic [IG_WIDTH-1:0] ig_wdata_load [N:0];
    logic [EG_WIDTH-1:0] eg_rdata_pop [N-1:0];
    logic [EG_WIDTH-1:0] eg_rdata_expected [N-1:0];
    string fn, d;
    integer fd ;

    int vcoFreq1;
    int vcoFreq2;
    int freqSw = 0;
    bit pllfull=0;
    int err_cnt;
    int freqRatio = 1;
    int gb_set = 1;
    int lp_set =1;

    integer rc;
    integer modeRegIdA;
    integer modeRegIdB;
    //virtual_sequencer   vsequencer;

    int vtdqsskew;
    int vtdqs2dqskew;
    int vtdqsqskew;
    int vtdqs2dq;
    int vtdqsq;
    int vtdqss_min;
    int vtdqss_max;
    int vtdqsck_min;
    int vtdqsck_max;
    int vtdqsck_min_b;
    int vtdqsck_max_b;

    wddr_config cfg;

    uvm_reg        local_reg;
    uvm_reg_field  local_reg_field;

    //   wddr_base_seq_sequencer  base_sequencer;

    virtual function void get_model();
        uvm_object temp_object;
        uvm_reg_block temp_reg_block;

        if(reg_model == null) begin
            if(uvm_config_object::get(null, "*", "reg_model", temp_object)) begin
                if(!($cast(reg_model,temp_object)))
                    `uvm_fatal("BAD_CONFIG", "Sequence reg model is inocrrect");
            end
            else if (uvm_config_db #(uvm_reg_block)::get(null, "*", "reg_model", temp_reg_block)) begin
                if(!($cast(reg_model, temp_reg_block)))
                    `uvm_fatal("ERROR_ID", "class_name not found in the UVM factory!");
            end
            else
                `uvm_fatal("NO_REG_CONFIG", "Reg Model is not set, Exiting");
        end
    endfunction : get_model

    virtual function void get_PREFIXES();

        uvm_config_db#(string)::get(null, "", "REG_INFIX",  REG_INFIX);
        uvm_config_db#(string)::get(null, "", "REG_PREFIX", REG_PREFIX);

    endfunction : get_PREFIXES

    virtual task pre_start();
        super.pre_start();
        get_model();
        get_PREFIXES();
    endtask

    // new - constructor
    function new(string name="wddr_base_seq");
        super.new(name);
        //trans=new;
        cfg = wddr_config::type_id::create("cfg");
        uvm_config_db#(wddr_config)::set(uvm_root::get(), "*", "cfg_obj", cfg);
    endfunction

    //`uvm_declare_p_sequencer(virtual_sequencer)

    // Raise in pre_body so the objection is only raised for root sequences.
    // There is no need to raise for sub-sequences since the root sequence
    // will encapsulate the sub-sequence.
    virtual task pre_body();
        if (starting_phase!=null) begin
            //            `uvm_info(get_type_name(), $sformatf("!s! pre_body() raising !s! objection", get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
            starting_phase.raise_objection(this);
        end
    endtask

    // Drop the objection in the post_body so the objection is removed when
    // the root sequence is complete.
    virtual task post_body();
        if (starting_phase!=null) begin
            `uvm_info(get_type_name(), $sformatf("%s post_body() dropping %s objection", get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
            starting_phase.drop_objection(this);
        end
    endtask

    virtual task body();

        if($value$plusargs("vcoFreq1=%0d",vcoFreq1))
        begin
            `uvm_info(get_type_name(), $sformatf("vcoFreq1: %0d MHz",vcoFreq1), UVM_LOW);
        end
        else
        begin
            vcoFreq1 = 806;

            `uvm_info(get_type_name(), $sformatf("vcoFreq1: %0d MHz",vcoFreq1), UVM_LOW);
        end

        if($value$plusargs("vcoFreq2=%0d",vcoFreq2))
        begin
            `uvm_info(get_type_name(), $sformatf("vcoFreq2: %0d MHz",vcoFreq2), UVM_LOW);
        end
        else
        begin
            vcoFreq2 = 806;
            `uvm_info(get_type_name(), $sformatf("vcoFreq2: %0d MHz",vcoFreq2), UVM_LOW);
        end

        if($value$plusargs("freqSw=%0d",freqSw))
        begin
            pllfull = 1;
            `uvm_info(get_type_name(), $sformatf("pllfull: %0d",pllfull), UVM_LOW);
        end

        if($value$plusargs("freqRatio=%0d",freqRatio))
        begin
            `uvm_info(get_type_name(), $sformatf("freqRatio: %0d",freqRatio), UVM_LOW);
        end

        if($value$plusargs("gb_set=%0d",gb_set))
        begin
            `uvm_info(get_type_name(), $sformatf("gb_set: %0d",gb_set), UVM_LOW);
        end

        if($value$plusargs("lp_set=%0d",lp_set))
        begin
            `uvm_info(get_type_name(), $sformatf("lp_set: %0d",lp_set), UVM_LOW);
        end

    endtask : body

    task automatic csr_write;
        input logic [AHB_AWIDTH-1:0] base;
        input logic [AHB_AWIDTH-1:0] addr;
        input logic [31:0]       data;
        uvm_reg_addr_t offset;
        begin
            offset = (base+addr);
            regstr = reg_model.MAP_APB.get_reg_by_offset(offset,0);
            regstr.write(status,data);
            $fdisplay(fd, "set_reg( {wddr_env_prfx,\"%s\"} , 32'h%x );", regstr.get_name ,data);
        end
    endtask

    task automatic csr_read;
        input  logic [AHB_AWIDTH-1:0] base;
        input  logic [AHB_AWIDTH-1:0] addr;
        output logic [31:0]       data;
        uvm_reg_addr_t offset;
        begin
            offset = (base+addr);
            regstr = reg_model.MAP_APB.get_reg_by_offset(offset,1);
            regstr.read(status,data);
        end
    endtask

    // task automatic wait_hclk;
    //     input integer noc;
    //     begin
    //         for(int i=0; i < noc; i ++) begin
    //             #104ns;
    //         end
    //     end
    // endtask

    task automatic config_vips;
        input integer freq;
        input integer fratio;
        begin

            cfg.set_freq(freq);
            cfg.set_fratio(fratio);
            cfg.gb_set=gb_set;
            void'(cfg.randomize());

            $fdisplay(fd, "//tphy_wrlat   = %d clk", cfg.tphy_wrlat);
            $fdisplay(fd, "//tphy_wrdata  = %d clk", cfg.tphy_wrdata);
            $fdisplay(fd, "//trddata_en   = %d clk", cfg.trddata_en);
            $fdisplay(fd, "//tphy_rdcslat = %d clk", cfg.tphy_rdcslat);
            $fdisplay(fd, "//tphy_rdlat   = %d clk", cfg.tphy_rdlat);

            uvm_config_db#(int)::set(uvm_root::get(), "*", "gap_rdwr", cfg.gap_rdwr);
            `uvm_info(get_type_name(), $sformatf("gap_rdwr: %0d",cfg.gap_rdwr), UVM_LOW);
            uvm_config_db#(int)::set(uvm_root::get(), "*", "gap_wrrd", cfg.gap_wrrd);
            uvm_config_db#(int)::set(uvm_root::get(), "*", "gap_rdrd", cfg.gap_rdrd);
            uvm_config_db#(int)::set(uvm_root::get(), "*", "gap_wrwr", cfg.gap_wrwr);
            uvm_config_db#(integer)::set(uvm_root::get(), "*", "freq_change", cfg.freq);
            uvm_config_db#(int)::set(uvm_root::get(), "*", "gb_set", cfg.gb_set);

            // Memory Model settings
            `ifndef LPK

            rc = $mmsomaset("wddr_tb_top.lp4", "trfcpb", cfg.trfcpb, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tcipw", cfg.tcipw, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "tdipw", cfg.tdipw, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "isDiffValidInSEMode", cfg.isDiffValidInSEMode);

            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsq", cfg.tdqsq, "ps");
            rc = $mmsomaset("wddr_tb_top.lp4", "trpre", cfg.trpre, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "trpst", 0.5, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqs2dq", cfg.tdqs2dq, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tescke", 0.75, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tcmdcke", 0.75, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tcscke", 0.75, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tcmdcke_minTck", cfg.tcmdcke_minTck, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "tescke_minTck", cfg.tescke_minTck, "clk");
            rc = $mmsomaset("wddr_tb_top.lp4", "tpbr2pbr", cfg.tpbr2pbr, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "tvrefweak", cfg.tvrefweak, "ns");
            rc = $mmsomaset("wddr_tb_top.lp4", "twdqstol", cfg.twdqstol, "clk");

            modeRegIdA = $mminstanceid ("wddr_tb_top.lp4(ChannelA)(modeReg)");
            rc = $mmwriteword4(modeRegIdA, 1, cfg.mr1);
            modeRegIdB = $mminstanceid ("wddr_tb_top.lp4(ChannelB)(modeReg)");
            rc = $mmwriteword4(modeRegIdB, 1, cfg.mr1);

            modeRegIdA = $mminstanceid ("wddr_tb_top.lp4(ChannelA)(modeReg)");
            rc = $mmwriteword4(modeRegIdA, 2, cfg.mr2);
            modeRegIdB = $mminstanceid ("wddr_tb_top.lp4(ChannelB)(modeReg)");
            rc = $mmwriteword4(modeRegIdB, 2, cfg.mr2);

            if(cfg.dbi)
            begin
                `uvm_info(get_type_name(), $sformatf("DBI is enabled"),UVM_LOW)
                modeRegIdA = $mminstanceid ("wddr_tb_top.lp4(ChannelA)(modeReg)");
                rc = $mmwriteword4(modeRegIdA, 3, 'hC2);
                modeRegIdB = $mminstanceid ("wddr_tb_top.lp4(ChannelB)(modeReg)");
                rc = $mmwriteword4(modeRegIdB, 3, 'hC2);
            end

            modeRegIdA = $mminstanceid ("wddr_tb_top.lp4(ChannelA)(modeReg)");
            rc = $mmwriteword4(modeRegIdA, 11, cfg.mr11);
            modeRegIdB = $mminstanceid ("wddr_tb_top.lp4(ChannelB)(modeReg)");
            rc = $mmwriteword4(modeRegIdB, 11, cfg.mr11);

            rc = $mmsomaset("wddr_tb_top.lp4", "tck_min_b", cfg.tck_min_b, "ps");

            if ($test$plusargs("WRMIN_DELAY"))
            begin
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_min", 0.75, "clk"); // Command to DQS -> WL + tdqss
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_max", 0.75, "clk");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqs2dq", 200, "ps"); // DQS to DQ -> tdqs2dq
            end
            else if ($test$plusargs("WRMAX_DELAY"))
            begin
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_min", 1.25, "clk");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_max", 1.25, "clk");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqs2dq", 800, "ps");
            end
            else
            begin
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_min", 0.75, "clk");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_max", 1.25, "clk");
            end

            if ($test$plusargs("RDMIN_DELAY"))
            begin
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_min", 1500, "ps"); // Command to DQS -> RL + tdqsck
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_max", 1500, "ps");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsq", 0, "clk"); // DQS to DQ -> tdqsq
            end

            if ($test$plusargs("RDMAX_DELAY"))
            begin
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_min", 3500, "ps");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_max", 3500, "ps");
                rc = $mmsomaset("wddr_tb_top.lp4", "tdqsq", 0.09, "clk");
            end

        `endif

        // Memory Controller settings
     `ifndef LPK
        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "tlp_resp", cfg.tlp_resp, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "tlp_resp", cfg.tlp_resp, "clk");

        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "tphy_wrlat", cfg.tphy_wrlat, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "tphy_wrlat", cfg.tphy_wrlat, "clk");
        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "tphy_wrdata", cfg.tphy_wrdata, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "tphy_wrdat", cfg.tphy_wrdata, "clk");
        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "tphy_rdlat", cfg.tphy_rdlat, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "tphy_rdlat", cfg.tphy_rdlat, "clk");
        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "tphy_rdcslat", cfg.tphy_rdcslat, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "tphy_rdcslat", cfg.tphy_rdcslat, "clk");
        rc = $mmsomaset("wddr_tb_top.activeDfiMCInst", "trddata_en", cfg.trddata_en, "clk");
        rc = $mmsomaset("wddr_tb_top.passiveDfiInst", "trddata_en", cfg.trddata_en, "clk");

        // LP4 Skew
        if($value$plusargs("tdqsskew=%0d",vtdqsskew))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsSkew", vtdqsskew, "ps");
        end

        if($value$plusargs("tdqs2dqskew=%0d",vtdqs2dqskew))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqs2dqSkew", vtdqs2dqskew, "ps");
        end

        if($value$plusargs("tdqsqskew=%0d",vtdqsqskew))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsqSkew", vtdqsqskew, "ps");
        end

        if($value$plusargs("tdqs2dq=%0d",vtdqs2dq))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqs2dq", vtdqs2dq, "ps");
        end

        if($value$plusargs("tdqsq=%0d",vtdqsq))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsq", vtdqsq, "clk");
        end

        if($value$plusargs("tdqss_min=%0d",vtdqss_min))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_min", vtdqss_min, "clk");
        end

        if($value$plusargs("tdqss_max=%0d",vtdqss_max))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqss_max", vtdqss_max, "clk");
        end

        if($value$plusargs("tdqsck_min=%0d",vtdqsck_min))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_min", vtdqsck_min, "ps");
        end

        if($value$plusargs("tdqsck_max=%0d",vtdqsck_max))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_max", vtdqsck_max, "ps");
        end

        if($value$plusargs("tdqsck_min_b=%0d",vtdqsck_min_b))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_min_b", vtdqsck_min_b, "ps");
        end

        if($value$plusargs("tdqsck_max_b=%0d",vtdqsck_max_b))
        begin
            rc = $mmsomaset("wddr_tb_top.lp4", "tdqsck_max_b", vtdqsck_max_b, "ps");
        end
     `endif

    end
endtask

///-----------------------------------------------------------------------
// MCU APIs - Begin
//-----------------------------------------------------------------------

task automatic check_mcu_exec_status ;
    output logic err = 0;
    logic [31:0] data3 = 0;
    string str;
    begin

        while (data3[0] != 1) begin
            reg_name = $sformatf("WDDR_MCU_MCU_MCU_GP3_CFG");
            regstr = reg_model.get_reg_by_name({reg_name});
            regstr.read(status, data3);

            if(data3[0] == 0 ) #300us;
        end

        if (data3[31:16] == 16'h0) begin
            `uvm_info(get_type_name(), $sformatf("MCU Program Execution Completed Succefully"),UVM_LOW)
        end
        else if (data3[31:16] != 16'h0) begin
            `uvm_error(get_type_name(), $sformatf("ERROR: MCU Program Execution Completed with an Error code. The 2byte error code = %h ", data3[31:16]));
            err = 1'b1 ;
        end
    end
endtask

task automatic check_irq;
    logic [31:0] data = 0;
    begin
        while(1)
        begin
            wait(wddr_tb_top.o_irq[0]);
            // Read the Msg Req
            reg_name = $sformatf("WDDR_MCU_MCUINTF_MCUINTF_MCU2HOST_MSG_REQ");
            regstr = reg_model.get_reg_by_name({reg_name});
            regstr.read(status, data);
            if ( data[0])
            begin
                // Read the Msg ID
                reg_name = $sformatf("WDDR_MCU_MCUINTF_MCUINTF_MCU2HOST_MSG_ID");
                regstr = reg_model.get_reg_by_name({reg_name});
                regstr.read(status, data);
                if ( data[31:0] == 32'h8000_0000 ) begin
                    // Read the Msg Data
                    reg_name = $sformatf("WDDR_MCU_MCUINTF_MCUINTF_MCU2HOST_MSG_DATA");
                    regstr = reg_model.get_reg_by_name({reg_name});
                    regstr.read(status, data);
                    `uvm_info(get_type_name(), $sformatf("[SW logging] MSG_DATA=%h",data),UVM_LOW)
                    // Write Clear REQ
                    reg_name = $sformatf("WDDR_MCU_MCUINTF_MCUINTF_MCU2HOST_MSG_REQ");
                    regstr = reg_model.get_reg_by_name({reg_name});
                    regstr.write(status, 1);
                    // Write the Msg Ack
                    reg_name = $sformatf("WDDR_MCU_MCUINTF_MCUINTF_MCU2HOST_MSG_ACK");
                    regstr = reg_model.get_reg_by_name({reg_name});
                    regstr.write(status, 1);
                end
            end
            #1us;
        end
    end
endtask

task automatic set_dfi_ca_traffic_ovr_cfg;
    input logic  sw_en ;
    input logic  sw_mode ;
    begin
        `CSR_WRF2(DDR_DFICH0_OFFSET,DDR_DFICH_CTRL1_M0_CFG, CA_TRAFFIC_OVR,      CA_TRAFFIC_OVR,     sw_en , sw_en );
        `CSR_WRF2(DDR_DFICH0_OFFSET,DDR_DFICH_CTRL1_M0_CFG, CA_TRAFFIC_OVR_SEL,  CA_TRAFFIC_OVR_SEL, sw_mode , sw_mode );
        `CSR_WRF2(DDR_DFICH0_OFFSET,DDR_DFICH_CTRL1_M1_CFG, CA_TRAFFIC_OVR,      CA_TRAFFIC_OVR,     sw_en , sw_en );
        `CSR_WRF2(DDR_DFICH0_OFFSET,DDR_DFICH_CTRL1_M1_CFG, CA_TRAFFIC_OVR_SEL,  CA_TRAFFIC_OVR_SEL, sw_mode , sw_mode );
    end
endtask

//-----------------------------------------------------------------------
// MCU APIs - End
//---------------------------------

`include "wddr_base_tasks.sv"
`include "wddr_base_m1_tasks.sv"
`include "ddr_sw_tasks.sv"
`include "wddr_dt_tasks.sv"
`include "wddr_bringup_tasks.sv"
`include "./dfi/wddr_DFI_tasks.sv"

function void print_prepost_fixes();
    `uvm_info(get_type_name(), $psprintf(" ALL PRE-POST-IN FIXES  - \n "), UVM_MEDIUM);
    `uvm_info(get_type_name(), $psprintf(" REG_PREFIX: %s" , REG_PREFIX   ), UVM_MEDIUM);
    `uvm_info(get_type_name(), $psprintf(" REG_INFIX: %s"  , REG_INFIX   ), UVM_MEDIUM);
    `uvm_info(get_type_name(), $psprintf(" SS_INFIX: %s"   , SS_INFIX   ), UVM_MEDIUM);
    `uvm_info(get_type_name(), $psprintf(" SER_SEL:   %s"  , SER_SEL     ), UVM_MEDIUM);
endfunction



    task automatic perform_write_2to1;
        wav_DFI_write_transfer trans = new();
        trans.is_rsp_required = 0;        
        trans.enable_randomization();
        assert(trans.randomize());
        
        wait_dfi_cycles(1);
            //ck_c ck_t dram clock enable 
            trans.dram_clk_disable[0] = 0;
            trans.dram_clk_disable[1] = 1;
            trans.dram_clk_disable[2] = 1;
            trans.dram_clk_disable[3] = 1;
            //enable ca dram bus
            trans.cke[0] = 2'b01;
            trans.cke[2] = 2'b01;
            trans.wck_cs = '{default: 2'b11};
            trans.wrdata_cs = '{default: 2'b11};
            trans.cs = '{default: 2'b11};

            trans.address = '{default: 0};

            trans.wck_en[0] = 1;
            trans.wck_en[1] = 0;
            trans.wck_en[2] = 0;
            trans.wck_en[3] = 1;
            //static
            trans.wck_toggle[0] = 2'b00;
            trans.wck_toggle[1] = 2'b00;
            trans.wck_toggle[2] = 2'b00;
            trans.wck_toggle[3] = 2'b00;
 
        `uvm_send(trans);

        wait_dfi_cycles(1);
            //ACT1
            trans.address[0] = 14'hffff;
            trans.address[2] = 14'hffff;
            // cs
            trans.cs[0] = 2'b01;
            trans.cs[2] = 2'b01;
        `uvm_send(trans);

        wait_dfi_cycles(1);
            //ACT2
            trans.address[0] = randomize_address(3'b011, 3'b111);
            trans.address[2] = randomize_address(0, 0); // totally random
        `uvm_send(trans);

        wait_dfi_cycles(1);
            //CAS_WR
            trans.address[0] = 14'b0000000_0011100;
            trans.address[2] = 14'b0000000_0000000;
        `uvm_send(trans);

        wait_dfi_cycles(1);
            //WR16
            trans.address[0] = randomize_address(3'b110, 3'b111);
            trans.address[2] = randomize_address(0, 0); // totally random
            // toggle 
            trans.wck_toggle[0] = 2'b01;
            trans.wck_toggle[2] = 2'b01;
            trans.wck_toggle[0] = 2'b01;
            trans.wck_toggle[2] = 2'b01;
        `uvm_send(trans);

        wait_dfi_cycles(1);      
            trans.cs[0] = 2'b00;
            trans.cs[2] = 2'b00;
            trans.address[0] = 14'b0000000_0000000;
            trans.address[2] = 14'b0000000_0000000;
            //finish of the commands before read (ACT1-ACT2-CASWR-WR16)
         `uvm_send(trans);

        wait_dfi_cycles(1); 
            //data
            // trans.wrdata[0] = 64'h0000_0000_1234_5678;
            // trans.wrdata[2] = 64'h0000_0000_abcd_ef98;
            assert(trans.randomize());
        `uvm_send(trans);

        /**************************** delay Tphy_wrdata between wrdata and wrdata_en ********************/
        /**************************** delay Tphy_wrdata between wr16 command and wrdata_en ********************/
        
        wait_dfi_cycles(1); 
            //wrdata enable 
            trans.wrdata_en[0] = 0;
            trans.wrdata_en[1] = 0;
            trans.wrdata_en[2] = 1;
            trans.wrdata_en[3] = 0;
        `uvm_send(trans);

        wait_dfi_cycles(1);      
            //ending the write transaction 
            trans.wrdata_en[3] = 0;
            trans.wrdata_cs[0] = 2'b00;
            trans.wrdata_cs[2] = 2'b00;
            // trans.wrdata[0] = 64'hzzzz_zzzz_zzzz_zzzz;
            // trans.wrdata[2] = 64'hzzzz_zzzz_zzzz_zzzz;
            trans.wrdata = '{default: 0};
            trans.wrdata_en[0] = 0;
            trans.wrdata_en[1] = 0;
            trans.wrdata_en[2] = 0;
            trans.wrdata_en[3] = 0;
        `uvm_send(trans);

        wait_dfi_cycles(2);        
            trans.wck_toggle[0] = 2'b00;
            trans.wck_toggle[1] = 2'b00;
            trans.wck_toggle[2] = 2'b00;
            trans.wck_toggle[3] = 2'b00;
        `uvm_send(trans);

        `uvm_info(get_type_name(), $psprintf("3.POST-CREATE, PPOST-RUN, PRE-RSP OF TRANSACTION"), UVM_LOW);

        `uvm_info(get_type_name(), "--------PRINTING THE REQ ITEM--------", UVM_DEBUG); 
        trans.print();

        repeat (10) wait_dfi_cycles(1); 
        trans = new();      // empty write transaction
        trans.is_rsp_required = 0;
        `uvm_send(trans);   // to reset the write interface
    endtask


    task automatic perform_control;
        int trans_type;

        trans_type = $urandom_range(0, 5);
        `uvm_info(get_name(), $psprintf("Starting the %0d transaction", i), UVM_MEDIUM);

        case (trans_type)
        0:  begin                   
            wav_DFI_lp_transfer trans = new();
            `uvm_info(get_name(), "Sending a lp_ctrl transaction", UVM_MEDIUM); 
            `uvm_create(trans);
            trans.is_rsp_required = 0;
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
            trans.is_rsp_required = 0;
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
            trans.is_rsp_required = 0;
            trans.req = 1'b1;
            trans.is_ctrl = 1'b1;
            `uvm_rand_send(trans);
            EventHandler::wait_for_transaction(EventHandler::ctrlupd);
            // get_response(rsp);
        end

        5: begin
            wav_DFI_status_transfer trans = wav_DFI_status_transfer::type_id::create("seq_item");
            trans.is_rsp_required = 0;
            assert(trans.randomize());
            `uvm_send(trans);
            EventHandler::wait_for_transaction(EventHandler::status);
            // get_response(rsp);
        end
        endcase
    endtask
endclass : wddr_base_seq
