coverage exclude -togglenode *jtag* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *ahb* 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *scan* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *freeze* 	-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -du *ahb* 
coverage exclude -du *cmn* 
coverage exclude -du *mcu* 
coverage exclude -du *_csr_wrapper
coverage exclude -togglenode *_sta 		-scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *_cfg	 	-scope /wddr_tb_top/u_phy_1x32 -r

run -all