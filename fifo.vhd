library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.jpeg_pkg.all;

entity fifo is
    generic (
        width : natural := 32;
        depth : integer := 64);
    port (
        reset : in std_logic;
        clock      : in std_logic;

        -- FIFO Write Interface
        write_en   : in  std_logic;
        write_data : in  std_logic_vector(width-1 downto 0);
        o_full    : out std_logic;

        -- FIFO Read Interface
        read_en   : in  std_logic;
        read_data : out std_logic_vector(width-1 downto 0);
        o_empty   : out std_logic);
end fifo;

architecture arch of fifo is

    type t_FIFO_DATA is array (0 to depth-1) of std_logic_vector(width-1 downto 0);
    signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));

    signal wr_index   : integer range 0 to depth-1 := 0;
    signal rd_index   : integer range 0 to depth-1 := 0;

    -- # Words in FIFO, has extra range to allow for assert conditions
    signal fifo_count : integer range -1 to depth+1 := 0;

    signal full  : std_logic;
    signal empty : std_logic;

begin

    p_CONTROL : process (clock) is
    begin
        if rising_edge(clock) then
            if reset = '1' then
                fifo_count <= 0;
                wr_index   <= 0;
                rd_index   <= 0;
            else

                -- Keeps track of the total number of words in the FIFO
                if (write_en = '1' and read_en = '0') then
                    fifo_count <= fifo_count + 1;
                elsif (write_en = '0' and read_en = '1') then
                    fifo_count <= fifo_count - 1;
                end if;

                -- Keeps track of the write index (and controls roll-over)
                if (write_en = '1' and full = '0') then
                    if wr_index = depth-1 then
                        wr_index <= 0;
                    else
                        wr_index <= wr_index + 1;
                    end if;
                end if;

                -- Keeps track of the read index (and controls roll-over)        
                if (read_en = '1' and empty = '0') then
                    if rd_index = depth-1 then
                        rd_index <= 0;
                    else
                        rd_index <= rd_index + 1;
                    end if;
                end if;

                -- Registers the input data when there is a write
                if write_en = '1' then
                    r_FIFO_DATA(wr_index) <= write_data;
                end if;
            end if;                           -- sync reset
        end if;                             -- rising_edge(clock)
    end process p_CONTROL;

    read_data <= r_FIFO_DATA(rd_index);

    full  <= '1' when fifo_count = depth else '0';
    empty <= '1' when fifo_count = 0       else '0';

    o_full  <= full;
    o_empty <= empty;
end arch;