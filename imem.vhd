library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_UNSIGNED.all; use IEEE.STD_LOGIC_ARITH.all;

entity imem is -- instruction memory, TP4 
	port (	a : 	in STD_LOGIC_VECTOR (5 downto 0);
			   rd:   out STD_LOGIC_VECTOR (31 downto 0));
end;

architecture behave of imem is
begin
	process(a)
		type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
		variable mem: ramtype;
	begin
	-- initialize memory 
		mem(0) := X"c1000002"; -- jal skip # Ceci va enoyer notre code a sauter la prochaine ligne 
 		mem(1) := X"ac02003C";	--     sw 	$v0, 60($0) 	# $v0(2) write M[60]; M[60]=0; # Devrait output error mais skipped par jal
		mem(2)  := X"20020005";	--     skip: addi $v0, $0, 5	   # $v0(2) = 5
		mem(3) := X"ac02003C";	--     sw 	$v0, 60($0) 	# $v0(2) write M[60]; M[60]=5; #Va output que jal a fonctionner
		mem(4) := X"1F108011";	--     index2A $v0, $0, $v0 	# $v0(2) devient v0 * 4 + adresse(0) donc v0 = 20
		mem(5) := X"ac02003C";	--     sw $v0, 60($0) # Call test2
		
		for ii in 06 to 63 loop
        mem(ii) := X"00000000";
      end loop;  -- ii
	-- read memory
		rd <= mem(CONV_INTEGER(a));
end process;
end;