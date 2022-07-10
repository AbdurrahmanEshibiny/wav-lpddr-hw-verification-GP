coverage exclude -togglenode *jtag* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *ahb* 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *scan* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *freeze* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *debug* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *_sta 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *_cfg	 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode sw_*_ovr	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode sw_*_val	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_ahb_ic -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_cmn -r				
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_csr_wrapper -r
coverage exclude -code abcdefst -scope /wddr_tb_top/u_phy_1x32/u_phy/u_mcu

coverage exclude -scope /wddr_tb_top/u_phy_1x32/u_phy/u_dfi/u_dfi_ctrl -srcfile ../rtl/wddr/ddr_dfi.sv -linerange 6677-6692

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

run -all