coverage exclude -togglenode *jtag* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *ahb* 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *scan* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *freeze* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *debug* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *irq* 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *sta* 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *cfg*	 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode sw_*_ovr	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode sw_*_val	-scope /wddr_tb_top/u_phy_1x32 -r

coverage exclude -togglenode *hw_event_0_cnt	-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode *hw_event_1_cnt	-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode i_event_0_en		-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode i_event_1_en		-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode i_event_0			-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode i_event_1			-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode event_0_edge		-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r
coverage exclude -togglenode event_1_edge		-scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -r


coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_ahb_ic -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_ahb_monitor -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_cmn -r				
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_csr_wrapper -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_mcu
coverage exclude -code a 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy_vddaon_island/u_aon_freeze_buf
coverage exclude -du *mcu*
coverage exclude -du *csr*
coverage exclude -du *cmn*
coverage exclude -du *jtag*
coverage exclude -du *ahb*
coverage exclude -du *freeze*
coverage exclude -du ddr_demet_s
coverage exclude -du ddr_edge_det

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -srcfile ../rtl/wddr/ddr_dfi.sv -linerange 6677-6692

coverage exclude -srcfile ../rtl/wddr/ddr_dfi.sv -linerange 13308-13309 13329-13331 13357-13358 13326-13327

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/REQ_RST_LO/u_demet_0 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/REQ_RST_LO/u_demet_1 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/ACK_RST_LO/u_demet_2 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/ACK_RST_LO/u_demet_3 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/u_demet_4 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/u_demet_5 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/u_demet_6 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_status_intf/u_demet_7 -r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_data_intf/NO_SW_REQ/u_demet_0 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_data_intf/ACK_RST_LO/u_demet_3 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_data_intf/u_demet_4 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_data_intf/u_demet_6 -r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_ctrl_intf/NO_SW_REQ/u_demet_0 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_ctrl_intf/ACK_RST_LO/u_demet_3 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_ctrl_intf/u_demet_4 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_lp_ctrl_intf/u_demet_6 -r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/NO_SW_REQ/u_demet_0 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/NO_SW_REQ/u_demet_1 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/ACK_RST_LO/u_demet_2 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/ACK_RST_LO/u_demet_3 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/u_demet_4 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_ctrlupd_intf/u_demet_6 -r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf -srcfile ../rtl/wddr/ddr_dfi.sv -linerange 13491-13495
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf -srcfile ../rtl/wddr/ddr_dfi.sv -linerange 13491-13495

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_0 -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_1	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_2	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_3	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_4	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phymstr_intf/u_demet_5	-r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_0  -r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_1	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_2	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_3	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_4	-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl/u_phyupd_intf/u_demet_5	-r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch0/u_phy_ca/CA_CSR_WRAPPER 		-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch0/u_phy_dq0/DQ_CSR_WRAPPER 		-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch0/u_phy_dq1/DQ_CSR_WRAPPER 		-r

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch1/u_phy_ca/CA_CSR_WRAPPER 		-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch1/u_phy_dq0/DQ_CSR_WRAPPER 		-r
coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_phy_ch1/u_phy_dq1/DQ_CSR_WRAPPER 		-r

coverage exclude -togglenode i_event i_req  -du work.ddr_dfi_eg_req_intf

coverage exclude -du work.ddr_dfi_eg_req_intf -ftrans fsm_state_q RH->AL AH->AL
coverage exclude -du work.ddr_dfi_ig_req_intf -ftrans fsm_state_q RH->AL AH->AL

coverage exclude -srcfile ./sv/register/wddr_reg_model.sv
coverage exclude -srcfile ../rtl/jtag/*
coverage exclude -srcfile ../rtl/ibex/*
coverage exclude -srcfile ../rtl/ahb/*
coverage exclude -srcfile ../rtl/mcu_ibex/*
coverage exclude -srcfile ../rtl/wddr/*ahb*
coverage exclude -srcfile ../rtl/wddr/*csr*
coverage exclude -srcfile ../rtl/wddr/*cmn*

run -all