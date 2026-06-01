-------------------------------------------------------------------------------
-- Module Name: freq_hop - Behavioral
-- Project Name: VDIF
-- Target Devices: Analog Devices AD9361 and Digilent ZedBoard
-- Tool Versions: Vivado 2022.2
-- Description: Digital Frequency Hopper
--
-- Revision:
-- Revision 0.01 - File Created
--
-- Additional Comments:
-- Separate DDS compiler used
-- Positioned between upack and rfifo
-- 1 clock cycle of latency
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_hop is
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;

        i_in      : in  std_logic_vector(15 downto 0);
        q_in      : in  std_logic_vector(15 downto 0);

        dds_data  : in  std_logic_vector(31 downto 0);

        valid_in  : in  std_logic;
        enable_in : in  std_logic;

        i_out      : out std_logic_vector(15 downto 0);
        q_out      : out std_logic_vector(15 downto 0);

        valid_out  : out std_logic;
        enable_out : out std_logic
    );
end freq_hop;

architecture Behavioral of freq_hop is
    signal dds_sin : std_logic_vector(15 downto 0);
    signal dds_cos : std_logic_vector(15 downto 0);

    signal i_mix_33 : signed(32 downto 0);
    signal q_mix_33 : signed(32 downto 0);
    
    signal valid_d1 : std_logic;
    signal enable_d1 : std_logic; 
    
begin
process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            valid_d1   <= '0';
            enable_d1  <= '0';
            valid_out  <= '0';
            enable_out <= '0';
            i_mix_33   <= (others => '0');
            q_mix_33   <= (others => '0');
            i_out      <= (others => '0');
            q_out      <= (others => '0');

        else
            valid_d1  <= valid_in;
            enable_d1 <= enable_in;

            valid_out  <= valid_d1;
            enable_out <= enable_d1;

            if valid_in = '1' and enable_in = '1' then
                i_mix_32 <= (signed(i_in) * signed(dds_data(15 downto 0))) -
                            (signed(q_in) * signed(dds_data(31 downto 16)));

                q_mix_32 <= (signed(i_in) * signed(dds_data(31 downto 16))) +
                            (signed(q_in) * signed(dds_data(15 downto 0)));
            end if;

            if valid_d1 = '1' and enable_d1 = '1' then
                i_out <= std_logic_vector(i_mix_32(30 downto 15));
                q_out <= std_logic_vector(q_mix_32(30 downto 15));
            else
                i_out <= (others => '0');
                q_out <= (others => '0');
            end if;
        end if;
    end if;
end process;
end Behavioral; 
