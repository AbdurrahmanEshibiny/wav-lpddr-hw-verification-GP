typedef struct packed {
    // bit /*[1:0]*/                i_dfi_cke_p0,
    // bit /*[1:0]*/                i_dfi_cke_p1,
    // bit /*[1:0]*/                i_dfi_cke_p2,
    // bit /*[1:0]*/                i_dfi_cke_p3,
    // bit /*[1:0]*/                i_dfi_cs_p0,
    // bit /*[1:0]*/                i_dfi_cs_p1,
    // bit /*[1:0]*/                i_dfi_cs_p2,
    // bit /*[1:0]*/                i_dfi_cs_p3,
    // bit                      i_dfi_dram_clk_disable_p0,
    // bit                      i_dfi_dram_clk_disable_p1,
    // bit                      i_dfi_dram_clk_disable_p2,
    // bit                      i_dfi_dram_clk_disable_p3,
 
    // bit                      i_dfi_parity_in_p0,
    // bit                      i_dfi_parity_in_p1,
    // bit                      i_dfi_parity_in_p2,
    // bit                      i_dfi_parity_in_p3,
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p0,
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p1,
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p2,
    // bit /*[1:0]*/                i_dfi_wrdata_cs_p3,
    // bit [7:0]                i_dfi_wrdata_mask_p0,
    // bit [7:0]                i_dfi_wrdata_mask_p1,
    // bit [7:0]                i_dfi_wrdata_mask_p2,
    // bit [7:0]                i_dfi_wrdata_mask_p3,
    // bit                      i_dfi_wrdata_en_p0,
    // bit                      i_dfi_wrdata_en_p1,
    // bit                      i_dfi_wrdata_en_p2,
    // bit                      i_dfi_wrdata_en_p3,
    bit /*[1:0]*/                i_dfi_wck_cs_p0;
    bit /*[1:0]*/                i_dfi_wck_cs_p1;
    bit /*[1:0]*/                i_dfi_wck_cs_p2;
    bit /*[1:0]*/                i_dfi_wck_cs_p3;
    bit                         i_dfi_wck_en_p0;
    bit                         i_dfi_wck_en_p1;
    bit                         i_dfi_wck_en_p2;
    bit                         i_dfi_wck_en_p3;
    bit /*[1:0]*/                i_dfi_wck_toggle_p0;
    bit /*[1:0]*/                i_dfi_wck_toggle_p1;
    bit /*[1:0]*/                i_dfi_wck_toggle_p2;
    bit /*[1:0]*/                i_dfi_wck_toggle_p3;
} wck_control;

class wck_c;
    randc wck_control values;
endclass //wck_c

class wddr_DFI_wck_seq extends wddr_base_seq;
    virtual wav_DFI_if vif;
    virtual gp_LPDDR5_channel_intf ch0_vif;
    virtual gp_LPDDR5_channel_intf ch1_vif;

    function new(string name="wddr_DFI_wck_seq");
        super.new(name);
    endfunction

    `uvm_object_utils(wddr_DFI_wck_seq)

    task automatic drive_wc(wck_control item);
        vif.wck_cs[0] <= {1'b0, item.i_dfi_wck_cs_p0};
        vif.wck_cs[1] <= {1'b0, item.i_dfi_wck_cs_p1};
        vif.wck_cs[2] <= {1'b0, item.i_dfi_wck_cs_p2};
        vif.wck_cs[3] <= {1'b0, item.i_dfi_wck_cs_p3};

        vif.wck_en[0] <= item.i_dfi_wck_en_p0;
        vif.wck_en[1] <= item.i_dfi_wck_en_p1;
        vif.wck_en[2] <= item.i_dfi_wck_en_p2;
        vif.wck_en[3] <= item.i_dfi_wck_en_p3;

        vif.wck_toggle[0] <= {1'b0, item.i_dfi_wck_toggle_p0};
        vif.wck_toggle[1] <= {1'b0, item.i_dfi_wck_toggle_p1};
        vif.wck_toggle[2] <= {1'b0, item.i_dfi_wck_toggle_p2};
        vif.wck_toggle[3] <= {1'b0, item.i_dfi_wck_toggle_p3};
    endtask //automatic

    function bit any_signal();
        return ch0_vif.dq0_wck_t != 'z || 
        ch0_vif.dq1_wck_t != 'z ||
        ch0_vif.dq0_wck_c != 'z || 
        ch0_vif.dq1_wck_c != 'z ||

        ch1_vif.dq0_wck_t != 'z || 
        ch1_vif.dq1_wck_t != 'z ||
        ch1_vif.dq0_wck_c != 'z || 
        ch1_vif.dq1_wck_c != 'z;
    endfunction

    virtual task body();
        bit err;
        wck_c item;
        super.body();
        ddr_boot(err);
        if (err != 0) begin
            `uvm_error(get_name(), $sformatf("sequence err_cnt <= %d ", err_cnt));
        end
        config_vips(200,1);
        item = new;
        if (!uvm_config_db#(virtual wav_DFI_if)::get(uvm_root::get(), "*", "DFI_vif", vif)) begin
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".DFI_vif"});
        end
        if(!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch0_vif", ch0_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
        end
        if(!uvm_config_db#(virtual gp_LPDDR5_channel_intf)::get(uvm_root::get(), "*", "ch1_vif", ch1_vif)) begin
			`uvm_fatal("gp_LPDDR5_monitor", "Failed to get virtual interface from config db")
		end

        @(posedge vif.clock);
        vif.cke[0]  <= 2'b01;
        vif.cs[0]	<= 2'b01;
        vif.cs[2]	<= 2'b01;
        vif.dram_clk_disable[0] <= 0;
        vif.dram_clk_disable[1] <= 1;
        vif.dram_clk_disable[2] <= 1;
        vif.dram_clk_disable[3] <= 1;

        forever begin
            assert(item.randomize());
            `uvm_info(get_name(), $psprintf("Trying values %0h", item.values), UVM_MEDIUM);            
            drive_wc(item.values);
            repeat(10) @(posedge vif.clock);
            if (any_signal()) begin
               `uvm_info(get_name(), "FINALLY!!!!!!!!!!!!!!!!!!!!!!!!!!", UVM_MEDIUM);                
                break;
            end
        end

    endtask : body

endclass