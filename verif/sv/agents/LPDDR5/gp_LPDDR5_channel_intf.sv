interface gp_LPDDR5_channel_intf(
	logic ddr_reset_n,
    logic ddr_rext,
    logic ddr_test
);

    logic ca0;
    logic ca1;
    logic ca2;
    logic ca3;
    logic ca4;
    logic ca5;
    logic ca6;
    logic cs0;
    logic cs1;
    logic ck_c;
    logic ck_t;

    logic dq0_wck_t;
    logic dq1_wck_t;
    logic dq0_wck_c;
    logic dq1_wck_c;
    logic dq0_dqs_t;
    logic dq1_dqs_t;
    logic dq0_dqs_c;
    logic dq1_dqs_c;
    logic dq0_dq0;
    logic dq0_dq1;
    logic dq0_dq2;
    logic dq0_dq3;
    logic dq0_dq4;
    logic dq0_dq5;
    logic dq0_dq6;
    logic dq0_dq7;
    logic dq0_dbim;
    logic dq1_dq0;
    logic dq1_dq1;
    logic dq1_dq2;
    logic dq1_dq3;
    logic dq1_dq4;
    logic dq1_dq5;
    logic dq1_dq6;
    logic dq1_dq7;
    logic dq1_dbim;

	logic [0:6] ca;
	assign ca = {ca0, ca1, ca2, ca3, ca4, ca5, ca6};

	logic cs;
	assign cs = cs0 | cs1;

	sequence PDE;
		@(posedge ck_t) (cs==1 && ca==7'b0000001) ##1 (cs==0);
	endsequence

	sequence ACT1;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b111);
	endsequence

	sequence ACT2;
		@(posedge ck_t) (cs==1 && ca[2:0]==3'b110);
	endsequence

	sequence PRE;
		@(posedge ck_t) (cs==1 && ca==7'b0001111);
	endsequence

	sequence REF;
		@(posedge ck_t) (cs==1 && ca==7'b0001110);
	endsequence

	sequence MWR;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b010);
	endsequence

	sequence WR16;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b011);
	endsequence

	sequence WR32;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0010);
	endsequence
	
	sequence RD16;
		@(posedge ck_t) (cs==1 && ca[0:2]==3'b100);
	endsequence

	sequence RD32;
		@(posedge ck_t) (cs==1 && ca[0:3]==3'b101);
	endsequence

	sequence CAS;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0011);
	endsequence

	sequence MPC;
		@(posedge ck_t) (cs==1 && ca[0:5]==6'b000011);
	endsequence

	sequence SRE;
		@(posedge ck_t) (cs==1 && ca==7'b0001011);
	endsequence

	sequence SRX;
		@(posedge ck_t) (cs==1 && ca[0:3]==4'b0010);
	endsequence

	sequence MRW1;
		@(posedge ck_t) (cs==1 && ca[0:6]==7'b0001101);
	endsequence

	sequence MRW2;
		@(posedge ck_t) (cs==1 && ca[0:5]==6'b000100);
	endsequence

	sequence MRR;
		@(posedge ck_t) (cs==1 && ca[0:6]==7'b0001100);
	endsequence

	sequence WFF;
		@(posedge ck_t) (cs==1 && ca==7'b0000011);
	endsequence

	sequence RFF;
		@(posedge ck_t) (cs==1 && ca==7'b0000010);
	endsequence

endinterface : gp_LPDDR5_channel_intf
