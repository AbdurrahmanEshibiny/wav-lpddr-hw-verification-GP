coverage exclude -togglenode *jtag* -scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *ahb* -scope /wddr_tb_top/u_phy_1x32 -r
coverage exclude -togglenode *scan* -scope /wddr_tb_top/u_phy_1x32 -r

run -all