library IEEE; use IEEE.STD_LOGIC_1164.all; use
IEEE.STD_LOGIC_ARITH.all;

entity datapath is -- MIPS datapath
	port(	clk, reset: in STD_LOGIC;
			memtoreg, pcsrc: in STD_LOGIC;
			alusrc, regdst: in STD_LOGIC;
			regwrite, jump: in STD_LOGIC;
			jal, index2A: in STD_LOGIC;
			alucontrol: in STD_LOGIC_VECTOR (2 downto 0);
			zero: out STD_LOGIC;
			pc: buffer STD_LOGIC_VECTOR (31 downto 0);
			instr: in STD_LOGIC_VECTOR(31 downto 0);
			aluout, writedata: buffer STD_LOGIC_VECTOR (31 downto 0);
			readdata: in STD_LOGIC_VECTOR(31 downto 0));
end;

architecture struct of datapath is
	component alu
		port(	a, b: in STD_LOGIC_VECTOR(31 downto 0);
				f   : in STD_LOGIC_VECTOR (2 downto 0);
				z   : out STD_LOGIC;
				y   : buffer STD_LOGIC_VECTOR(31 downto 0));
	end component;
	component regfile
		port(	clk: in STD_LOGIC;
				we3: in STD_LOGIC;
				ra1, ra2, wa3: in STD_LOGIC_VECTOR (4 downto 0);
				wd3: in STD_LOGIC_VECTOR (31 downto 0);
				rd1, rd2: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component adder
		port(	a, b: in STD_LOGIC_VECTOR (31 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component sl2
		port(	a: in STD_LOGIC_VECTOR (31 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component signext
		port(	a: in STD_LOGIC_VECTOR (15 downto 0);
				y: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
	component flopr generic (width: integer);
		port(	clk, reset: in STD_LOGIC;
				d: in STD_LOGIC_VECTOR (width-1 downto 0);
				q: out STD_LOGIC_VECTOR (width-1 downto 0));
	end component;
	component mux2 generic (width: integer);
		port(	d0, d1: in STD_LOGIC_VECTOR (width-1 downto 0);
				s: in STD_LOGIC;
				y: out STD_LOGIC_VECTOR (width-1 downto 0));
	end component;
	
	signal writereg: STD_LOGIC_VECTOR (4 downto 0);
	signal pcjump, pcnext, pcnextbr, pcplus4, pcbranch: STD_LOGIC_VECTOR (31 downto 0);
	signal signimm, signimmsh: STD_LOGIC_VECTOR (31 downto 0);
	signal srca, srcb, result: STD_LOGIC_VECTOR (31 downto 0);
	--New signals for jal
	signal srcA3: STD_LOGIC_VECTOR(4 downto 0);
	signal srcWD3: STD_LOGIC_VECTOR (31 downto 0);
	--signals for index2A ALU add, write to WD3 
	signal srcRD1: STD_LOGIC_VECTOR(4 downto 0);
	signal srcRD2: STD_LOGIC_VECTOR(4 downto 0);
	signal RD1sll: STD_LOGIC_VECTOR(4 downto 0);
	signal in2A: STD_LOGIC_VECTOR(4 downto 0);

	
begin
-- next PC logic
	pcjump <= pcplus4 (31 downto 28) & instr (25 downto 0) & "00";
	pcreg: flopr generic map(32) port map(clk, reset, pcnext, pc);
	pcadd1: adder port map(pc, X"00000004", pcplus4);
	immsh: sl2 port map(signimm, signimmsh);
	pcadd2: adder port map(pcplus4, signimmsh, pcbranch);
	pcbrmux: mux2 generic map(32) port map(pcplus4, pcbranch, pcsrc, pcnextbr);
	pcmux: mux2 generic map(32) port map(pcnextbr, pcjump, jump, pcnext);
-- register file logic

	--Les donnes qui sont ecrite sur RA sont PC + 4
	dateWrittenSource: mux2 generic map(32) port map(result, pcplus4, jal, srcWD3);\
	-- On modifie l'entree pour le Register file selon jal
	srcA3mux: mux2 generic map (5) port map(writereg, "11111", jal, srcA3);

	--Rd = 4RD1+RD2
	srcRD12sll: sl2 port map(srcRD1, RD1sll); --4RD1
	index2Adr: mux2 generic map(32) port map(srcRD1, RD1sll, index2A, in2A);
	index2ArResult: alu port map(srcRD2, in2A, "010", zero, srcWD3); --result of index2A now on WD3
	--srcWD3 est pret pour rf
 
	wrmux: mux2 generic map(5) port map(instr(20 downto 16),instr(15 downto 11), regdst, writereg);
	rf: regfile port map(clk, regwrite, instr(25 downto 21),instr(20 downto 16), srcA3, srcWD3, srca, writedata);
	resmux: mux2 generic map(32) port map(aluout, readdata, memtoreg, result);
	se: signext port map(instr(15 downto 0), signimm);



	
	
	
-- ALU logic
	srcbmux: mux2 generic map (32) port map(writedata, signimm, alusrc, srcb);
	mainalu: alu port map(srca, srcb, alucontrol, zero, aluout);
end;