-- importando as bibliotecas
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY Processador IS
	PORT
	(
		datain		   			:  IN  std_logic_vector(9 DOWNTO 0); 					  -- vetor de dados unidirecionais datain de 8 bits
		dataout	      			:  OUT std_logic_vector(6 DOWNTO 0); 					  -- vetor de dados unidirecionais dataout de 8 bits
		DISPLAY        			:  OUT std_logic_vector(34 downto 0) 					  -- vertor do DISPLAY para a placa		
	);
end Processador;

ARCHITECTURE CPU OF Processador IS 																  -- opções para os processamentos disponíveis

	constant ULAadd 			   :  std_logic_vector(9 downto 0)     := "0000000000"; -- para todos os pinos desligados (adição)
	constant ULAsub 			   :  std_logic_vector(9 downto 0)     := "1000000000"; -- para 1º pino levantado (subtração)
	constant ULAdiv				:  std_logic_vector(9 downto 0)     := "0100000000"; -- para 2º pino levantado (divisão)
	constant ULAmult	 			:  std_logic_vector(9 downto 0)     := "0010000000"; -- para 3º pino levantado (multiplicação)
	constant ULAmaior 			:  std_logic_vector(9 downto 0)     := "0001000000"; -- para 4º pino levantado (maior)
	constant ULAmenor 			:  std_logic_vector(9 downto 0)     := "0000100000"; -- para 5º pino levantado (menor)
	constant ULAmaiorigual 		:  std_logic_vector(9 downto 0)     := "0000010000"; -- para 6º pino levantado (maior/igual)
	constant ULAmenorigual 		:  std_logic_vector(9 downto 0)     := "0000001000"; -- para 7º pino levantado (menor/igual)
	constant ULAigual 			:  std_logic_vector(9 downto 0)     := "0000000100"; -- para 8º pino levantado (número iguais)
	constant ULAdiferente 	   :  std_logic_vector(9 downto 0)     := "0000000010"; -- para 9º pino levantado (número diferente)
	constant JUMP					:  std_logic_vector(9 downto 0)     := "0000000001"; -- para 10º pino levantado (JUMPER)
	constant LOAD					:  std_logic_vector(9 downto 0)     := "1000000001"; -- para o 1º e 10º pinos levantados (LOAD) 
	constant STORE				   :  std_logic_vector(9 downto 0)     := "1000000010"; -- para o 1º e 9º pinos levantados (STORE)
	constant MOV					:  std_logic_vector(9 downto 0)     := "1000000100"; -- para o 1º e 8º pinos levantados (MOV)

   signal resultado 	  			:  std_logic_vector(3 downto 0); 				  		  -- para armazenar os resultados das operações
	signal auxregister    	   :  std_logic_vector(7 downto 0); 				  		  -- para o registrador auxiliar
   signal PC               	:  std_logic_vector(9 downto 0); 				  		  -- para o Program Counter
	signal A                	:  std_logic_vector(3 downto 0);					  		  -- vetor A
	signal B                	:  std_logic_vector(3 downto 0);					  		  -- vetor B
	signal aux              	:  std_logic_vector(7 downto 0);					  		  -- vetor auxiliar
	signal numero 					:  std_logic_vector(7 downto 0)		:= "00000001" ;  -- vetor que guarda o número escolhido
   signal auxint, auxintA, auxintB   		:  INTEGER;								  		  -- auxiliar inteiro, de A e B
   signal endereco         					:  INTEGER;								  		  -- inteiro que guarda o endereço

    TYPE matrizdamemoria is array (0 to 4) of std_logic_vector(7 downto 0);  		  -- Matriz responsável pela memória
	 SIGNAL memoria: matrizdamemoria;

	TYPE matrizdados is array (0 to 15) of std_logic_vector(7 downto 0); 	  		  -- Matriz responsável pelo registrador
	SIGNAL registrador: matrizdados :=
	(
	
		"00000000",
		"00010000",
		"00100000",
		"00110000",
		"01000000",
		"01010000",
		"01100000",
		"01110000",
		"10000000",
		"10010000",
		"10100000",
	   "10110000",
		"11000000",
		"11010000",
		"00000000",
		"00010000"
		
	);
	
	begin
		process(datain)
		begin
			
			endereco <= conv_integer(registrador(0)(3 downto 0)); -- recebe o endereço do registrador na posição 0 da matriz do registrador

			memoria(endereco) <= "01000010"; -- colocando um valor pré definido no inicio na memória - 0100 = 4 e 0010 = 2

			PC <= datain; 							-- PC recebe os 4 primeiros bits do registrador de 8 bits para escolher a função
		
			aux <= memoria(endereco); 			-- Os valores são coletados e divido entre dois valores
			A <= aux(7 downto 4);
			B <= aux(3 downto 0);

			case PC is 								-- este case é resposável pelas escolhar das opções realizadas na placa
				when ULAadd =>						-- quando a ULA escolhida é de adição
					resultado <= A + B ;

                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      	-- case resposável pelo decodificador
							   when 0 => DISPLAY <= "11111111111111100000001000010001000";
				            when 1 => DISPLAY <= "11111111111111111100101000010001000";
				            when 2 => DISPLAY <= "11111111111111010010001000010001000";
				            when 3 => DISPLAY <= "11111111111111011000001000010001000";
				            when 4 => DISPLAY <= "11111111111111001100101000010001000";
				            when 5 => DISPLAY <= "11111111111111001001001000010001000";
				            when 6 => DISPLAY <= "11111111111111000001001000010001000";
				            when 7 => DISPLAY <= "11111111111111011100001000010001000";
				            when 8 => DISPLAY <= "11111111111111000000001000010001000";
				            when 9 => DISPLAY <= "11111111111111001100001000010001000";
				            when others => NULL;
                   end case;


				when ULAsub =>					  -- quando a ULA escolhida é de subtração
					resultado <= A - B ;
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000010000010010010";
                       when 1 => DISPLAY <= "11111111111111111100110000010010010";
                       when 2 => DISPLAY <= "11111111111111010010010000010010010";
                       when 3 => DISPLAY <= "11111111111111011000010000010010010";
                       when 4 => DISPLAY <= "11111111111111001100110000010010010";
                       when 5 => DISPLAY <= "11111111111111001001010000010010010";
                       when 6 => DISPLAY <= "11111111111111000001010000010010010";
                       when 7 => DISPLAY <= "11111111111111011100010000010010010";
                       when 8 => DISPLAY <= "11111111111111000000010000010010010";
                       when 9 => DISPLAY <= "11111111111111001100010000010010010";
                       when others => NULL;
                    end case;

				when ULAmult =>				  -- quando a ULA escolhida é de multiplicação
					resultado <= std_logic_vector(to_unsigned((to_integer(unsigned(A)) * to_integer(unsigned(B))), 4));
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000010000011001000";
                       when 1 => DISPLAY <= "11111111111111111100110000011001000";
                       when 2 => DISPLAY <= "11111111111111010010010000011001000";
                       when 3 => DISPLAY <= "11111111111111011000010000011001000";
                       when 4 => DISPLAY <= "11111111111111001100110000011001000";
                       when 5 => DISPLAY <= "11111111111111001001010000011001000";
                       when 6 => DISPLAY <= "11111111111111000001010000011001000";
                       when 7 => DISPLAY <= "11111111111111011100010000011001000";
                       when 8 => DISPLAY <= "11111111111111000000010000011001000";
                       when 9 => DISPLAY <= "11111111111111001100010000011001000";
                       when others => NULL;
                    end case;

				when ULAdiv =>				  	  -- quando a ULA escolhida é de divisão
					resultado <= std_logic_vector(to_unsigned(to_integer(unsigned(A)) / to_integer(unsigned(B)), 4));
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000011110010100001";
                       when 1 => DISPLAY <= "11111111111111111100111110010100001";
                       when 2 => DISPLAY <= "11111111111111010010011110010100001";
                       when 3 => DISPLAY <= "11111111111111011000011110010100001";
                       when 4 => DISPLAY <= "11111111111111001100111110010100001";
                       when 5 => DISPLAY <= "11111111111111001001011110010100001";
                       when 6 => DISPLAY <= "11111111111111000001011110010100001";
                       when 7 => DISPLAY <= "11111111111111011100011110010100001";
                       when 8 => DISPLAY <= "11111111111111000000011110010100001";
                       when 9 => DISPLAY <= "11111111111111001100011110010100001";
                       when others => NULL; 
                    end case;

				when ULAmaior =>				  -- quando a ULA escolhida é de maior que
					if(A > B) then				  -- fará a comparação para saber se A > B
						resultado <= x"1" ;    -- número "1" vai ser multiplicado por 4 e o seu valor será guardado em X, como é um único número retorna 4 bits, caso possuisse 2 números retornaria 8 bits
					else							
						resultado <= x"0" ;
					end if;
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000011111110110011";
                       when 1 => DISPLAY <= "11111111111111111100111111110110011";
                       when 2 => DISPLAY <= "11111111111111010010011111110110011";
                       when 3 => DISPLAY <= "11111111111111011000011111110110011";
                       when 4 => DISPLAY <= "11111111111111001100111111110110011";
                       when 5 => DISPLAY <= "11111111111111001001011111110110011";
                       when 6 => DISPLAY <= "11111111111111000001011111110110011";
                       when 7 => DISPLAY <= "11111111111111011100011111110110011";
                       when 8 => DISPLAY <= "11111111111111000000011111110110011";
                       when 9 => DISPLAY <= "11111111111111001100011111110110011";
                       when others => NULL;
                    end case;

				when ULAmenor =>				  -- quando a ULA escolhida é de menor que
					if(A < B) then				  -- fará a comparação para saber se A < B
						resultado <= x"1" ;	  -- número "1" vai ser multiplicado por 4 e o seu valor será guardado em X, como é um único número retorna 4 bits, caso possuisse 2 números retornaria 8 bits						
					else
						resultado <= x"0" ;
					end if;
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000011111110100111";
                       when 1 => DISPLAY <= "11111111111111111100111111110100111";
                       when 2 => DISPLAY <= "11111111111111010010011111110100111";
                       when 3 => DISPLAY <= "11111111111111011000011111110100111";
                       when 4 => DISPLAY <= "11111111111111001100111111110100111";
                       when 5 => DISPLAY <= "11111111111111001001011111110100111";
                       when 6 => DISPLAY <= "11111111111111000001011111110100111";
                       when 7 => DISPLAY <= "11111111111111011100011111110100111";
                       when 8 => DISPLAY <= "11111111111111000000011111110100111";
                       when 9 => DISPLAY <= "11111111111111001100011111110100111";
                       when others => NULL;
                   end case;

				when ULAmaiorigual =>			-- quando a ULA escolhida é de maior/igual que
					if(A >= B) then			   -- fará a comparação para saber se A > B ou de A == B
						resultado <= x"1" ;
					else
                  resultado <= x"0" ;
           		end if;
					
                   auxint <= CONV_INTEGER(resultado);
						 
			        case(auxint) is       	-- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000001101110110011";
                       when 1 => DISPLAY <= "11111111111111111100101101110110011";
                       when 2 => DISPLAY <= "11111111111111010010001101110110011";
                       when 3 => DISPLAY <= "11111111111111011000001101110110011";
                       when 4 => DISPLAY <= "11111111111111001100101101110110011";
                       when 5 => DISPLAY <= "11111111111111001001001101110110011";
                       when 6 => DISPLAY <= "11111111111111000001001101110110011";
                       when 7 => DISPLAY <= "11111111111111011100001101110110011";
                       when 8 => DISPLAY <= "11111111111111000000001101110110011";
                       when 9 => DISPLAY <= "11111111111111001100001101110110011";
                       when others => NULL;
                    end case;

				when ULAmenorigual =>	     	-- quando a ULA escolhida é de menor/igual que
					if(A <= B) then				-- fará a comparação para saber se A < B ou de A == B
                  resultado <= x"1" ;
               else
						resultado <= x"0" ;
               end if;
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000001101110100111";
                       when 1 => DISPLAY <= "11111111111111111100101101110100111";
                       when 2 => DISPLAY <= "11111111111111010010001101110100111";
                       when 3 => DISPLAY <= "11111111111111011000001101110100111";
                       when 4 => DISPLAY <= "11111111111111001100101101110100111";
                       when 5 => DISPLAY <= "11111111111111001001001101110100111";
                       when 6 => DISPLAY <= "11111111111111000001001101110100111";
                       when 7 => DISPLAY <= "11111111111111011100001101110100111";
                       when 8 => DISPLAY <= "11111111111111000000001101110100111";
                       when 9 => DISPLAY <= "11111111111111001100001101110100111";
                       when others => NULL;
                   end case;

				when ULAigual =>		 			-- quando a ULA escolhida é de igual que
					if(A = B) then					-- fará a comparação para saber A == B
						resultado <= x"1" ;
               else
                  resultado <= x"0" ;
               end if;

							auxint <= CONV_INTEGER(resultado);
							
                     case(auxint) is     -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000001101110110111";
                       when 1 => DISPLAY <= "11111111111111111100101101110110111";
                       when 2 => DISPLAY <= "11111111111111010010001101110110111";
                       when 3 => DISPLAY <= "11111111111111011000001101110110111";
                       when 4 => DISPLAY <= "11111111111111001100101101110110111";
                       when 5 => DISPLAY <= "11111111111111001001001101110110111";
                       when 6 => DISPLAY <= "11111111111111000001001101110110111";
                       when 7 => DISPLAY <= "11111111111111011100001101110110111";
                       when 8 => DISPLAY <= "11111111111111000000001101110110111";
                       when 9 => DISPLAY <= "11111111111111001100001101110110111";
                       when others => NULL;
                    end case;

				when ULAdiferente => 			-- quando a ULA escolhida é de diferente que
					if(A /= B) then				-- fará a comparação para saber A != B
                  resultado <= x"1" ;
               else
						resultado <= x"0" ;
               end if;
					
                    auxint <= CONV_INTEGER(resultado);
						  
                    case(auxint) is      -- case resposável pelo decodificador
							  when 0 => DISPLAY <= "11111111111111100000000011100100001";
                       when 1 => DISPLAY <= "11111111111111111100100011100100001";
                       when 2 => DISPLAY <= "11111111111111010010000011100100001";
                       when 3 => DISPLAY <= "11111111111111011000000011100100001";
                       when 4 => DISPLAY <= "11111111111111001100100011100100001";
                       when 5 => DISPLAY <= "11111111111111001001000011100100001";
                       when 6 => DISPLAY <= "11111111111111000001000011100100001";
                       when 7 => DISPLAY <= "11111111111111011100000011100100001";
                       when 8 => DISPLAY <= "11111111111111000000000011100100001";
                       when 9 => DISPLAY <= "11111111111111001100000011100100001";
                       when others => NULL;
                    end case;

				when JUMP => -- dado um endereço de memória o contador de programa pula para o endereço específico no JUMP
                    DISPLAY <= "11111111111111111111100011001110001";

				when LOAD => -- carrega o conteúdo de um endereço de memória para o registrador
				
                    aux <= memoria(endereco);
                    auxintA  <= CONV_INTEGER(aux(7 downto 4));
                    auxintB  <= CONV_INTEGER(aux(3 downto 0));

					case(auxintA) is      	 -- case resposável pelo decodificador																																
							   when 0 => DISPLAY <= "11111111111111111111101000011000111";
				            when 1 => DISPLAY <= "11111111111111111111101000011000111";
				            when 2 => DISPLAY <= "11111111111111111111101000011000111";
				            when 3 => DISPLAY <= "11111111111111111111101000011000111";
				            when 4 => DISPLAY <= "11111111111111111111101000011000111";
				            when 5 => DISPLAY <= "11111111111111111111101000011000111";
				            when 6 => DISPLAY <= "11111111111111111111101000011000111";
				            when 7 => DISPLAY <= "11111111111111111111101000011000111";
				            when 8 => DISPLAY <= "11111111111111111111101000011000111";
				            when 9 => DISPLAY <= "11111111111111111111101000011000111";
				            when others => NULL;
					 end case;

					 case(auxintB) is         -- case resposável pelo decodificador
            			   when 0 => DISPLAY <=    "11111111111111111111101000011000111";
					 			when 1 => DISPLAY <= "11111111111111111111101000011000111";
					 			when 2 => DISPLAY <= "11111111111111111111101000011000111";
					 			when 3 => DISPLAY <= "11111111111111111111101000011000111";
								when 4 => DISPLAY <= "11111111111111111111101000011000111";
								when 5 => DISPLAY <= "11111111111111111111101000011000111";
								when 6 => DISPLAY <= "11111111111111111111101000011000111";
								when 7 => DISPLAY <= "11111111111111111111101000011000111";
								when 8 => DISPLAY <= "11111111111111111111101000011000111";
								when 9 => DISPLAY <= "11111111111111111111101000011000111";
					 when others => NULL;
					 end case;
		
				when STORE => -- salva o conteúdo do registrador em um endereço de memória
				
					memoria(endereco) <= numero;
					endereco <= endereco + 1;
               DISPLAY <= "11111111111111111111100001100010010";

				when MOV => -- move conteúdo de um registrador para outro
				
					auxregister <= registrador(14);
					registrador(14) <= registrador(15); -- modifica o segundo valor da memória pelo terceiro valor da memória
					registrador(15) <= auxregister;
               DISPLAY <= "11111111111111111111110000001001000";
					
				when others => NULL;
				
			end case;
	end process;
end CPU;
