library IEEE; use IEEE.STD_LOGIC_1164.all;

entity maindec is -- main control decoder
	port (op: in STD_LOGIC_VECTOR (5 downto 0);
			memtoreg, memwrite: out STD_LOGIC;
			branch, alusrc: out STD_LOGIC;
			regdst, regwrite: out STD_LOGIC;
			jump: out STD_LOGIC;
			jal, index2A: out STD_LOGIC;
			aluop: out STD_LOGIC_VECTOR (1 downto 0)
			);
end;

architecture behave of maindec is
	signal controls: STD_LOGIC_VECTOR(10 downto 0);
begin
process(op) begin
	case op is
		when "000000" => controls <= "00110000010"; -- Rtyp
		when "100011" => controls <= "00101001000"; -- LW
		when "101011" => controls <= "00001010000"; -- SW
		when "000100" => controls <= "00000100001"; -- BEQ
		when "000010" => controls <= "00000000100"; -- J
		when "001000" => controls <= "00101000000"; -- ADDI
		when "000011" => controls <= "01100000100"; --JAL
		when "010001" => controls <= "10100010000"; --Index2Add
		when others => controls <= "-----------"; -- illegal op
	end case;
end process;
	jal <= controls(9);
	index2A <= controls(10);
	regwrite <= controls(8);
	regdst <= controls(7);
	alusrc <= controls(6);
	branch <= controls(5);
	memwrite <= controls(4);
	memtoreg <= controls(3);
	jump <= controls(2);
	aluop <= controls(1 downto 0);
end;