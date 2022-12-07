/* MODIFY. The cache controller. It is a state machine
that controls the behavior of the cache. */

module l2_cache_control (
    input logic clk,
    input logic rst, 
    input logic lru_out, dirty0_out, dirty1_out, valid0_out, valid1_out, hit0, hit1,
    
    input logic [31:0] mem_byte_enable256,
    input logic mem_read, mem_write,
    input logic pmem_resp,
    
    output logic lru_in, dirty0_in, dirty1_in, valid0_in, valid1_in,
    output logic ld_dirty0, ld_dirty1, ld_valid0, ld_valid1, ld_lru, ld_tag0, ld_tag1,
    output logic rd_data0, rd_data1, rd_dirty0, rd_dirty1, rd_valid0, rd_valid1, rd_lru, rd_tag0, rd_tag1, 
    output logic datain0_sel, datain1_sel, pmem_read, pmem_write, mem_resp,

    output logic mem_addr_sel, 
    output logic [31:0] byte_enable0, byte_enable1
);

enum int unsigned {
	idle, cache_access, write_back, read, done
} state, next_state;

function void set_defaults();

    rd_lru = 1'b1;
    rd_data0 = 1'b1;
    rd_data1 = 1'b1;
    rd_dirty0 = 1'b1;
    rd_dirty1 = 1'b1; 
    rd_valid0 = 1'b1; 
    rd_valid1 = 1'b1;
    rd_tag0 = 1'b1; 
    rd_tag1 = 1'b1;

    ld_lru = 1'b0;
    ld_dirty0 = 1'b0;
    ld_dirty1 = 1'b0;
    ld_valid0 = 1'b0;
    ld_valid1 = 1'b0;
    ld_tag0 = 1'b0;
    ld_tag1 = 1'b0;

    dirty0_in = dirty0_out;
    dirty1_in = dirty1_out;
    valid0_in = valid0_out;
    valid1_in = valid1_out;

    byte_enable0 = {32{1'b0}};
    byte_enable1 = {32{1'b0}};

	mem_addr_sel = 1'b0;
	datain0_sel = 1'b0;
	datain1_sel = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;

    mem_resp = 1'b0;
endfunction

function void write_to_mem();
    pmem_write = 1'b1;
    mem_addr_sel = 1'b1; 
endfunction

always_comb
begin : state_actions
    set_defaults();
	case(state)
	    idle: ;

	    cache_access: begin
            if (hit0) begin
                mem_resp = 1'b1;
	            lru_in = 1'b1;
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit1) begin
                mem_resp = 1'b1;
	            lru_in = 1'b0;
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

		    if(hit0 && mem_write) begin
				dirty0_in = 1'b1;
				ld_dirty0 = 1'b1; rd_dirty0 = 1'b0;
				byte_enable0 = mem_byte_enable256; rd_data0 = 1'b0;
			end

			else if (hit1 && mem_write) begin
				dirty1_in = 1'b1;
				ld_dirty1 = 1'b1; rd_dirty0 = 1'b0;
				byte_enable1 = mem_byte_enable256; rd_data1 = 1'b1;
			end
        end

        write_back: begin
            write_to_mem(); 
        end

        read: begin
            if(~lru_out) begin
                datain0_sel = 1'b1;
				ld_tag0 = 1'b1; rd_tag0 = 1'b0;
				dirty0_in = 1'b0;
				ld_dirty0 = 1'b1; rd_dirty0 = 1'b0;
                valid0_in = 1'b1;
                ld_valid0 = 1'b1; rd_valid0 = 1'b0;
                byte_enable0 = {32{1'b1}}; rd_data0 = 1'b0;
            end

            else if (lru_out) begin
                datain1_sel = 1'b1;
				ld_tag1 = 1'b1; rd_tag1 = 1'b0;
				dirty1_in = 1'b0;
				ld_dirty1 = 1'b1; rd_dirty1 = 1'b0; 
                valid1_in = 1'b1;
				ld_valid1 = 1'b1; rd_valid1 = 1'b0;
                byte_enable1 = {32{1'b1}}; rd_data1 = 1'b0;
            end

            pmem_read = 1'b1;
            mem_addr_sel = 1'b0;
        end

        done: begin
            if(~lru_out && mem_write) begin
                dirty0_in = 1'b1;
                ld_dirty0 = 1'b1; rd_dirty0 = 1'b0;
                byte_enable0 = mem_byte_enable256; rd_data0 = 1'b0;
            end

            else if(lru_out && mem_write) begin
                dirty1_in = 1'b1;
                ld_dirty1 = 1'b1; rd_dirty1 = 1'b0;
                byte_enable1 = mem_byte_enable256; rd_data1 = 1'b0;                       
            end

            if (hit0) begin
                mem_resp = 1'b1;
	            lru_in = 1'b1;
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end

            else if (hit1) begin
                mem_resp = 1'b1;
	            lru_in = 1'b0;
	            ld_lru = 1'b1;
                rd_lru = 1'b0;
            end
        end
    endcase
end


always_comb
begin : next_state_logic
	unique case(state)
		idle: begin
            if (mem_read | mem_write) next_state = cache_access;
            else next_state = idle;
        end

		cache_access: begin
		    if(hit0 | hit1) next_state = idle;
		    else if(~lru_out && dirty0_out && valid0_out) next_state = write_back;
		    else if(lru_out && dirty1_out && valid1_out) next_state = write_back;
            else next_state = read;   
        end

        write_back: begin
            if(pmem_resp) next_state = read;
            else next_state = write_back;
        end

        read: begin
            if(pmem_resp) next_state = done;
            else next_state = read;
        end

        done: begin
            next_state = idle;
        end
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    if (rst)
        state <= idle;
    else state <= next_state;
end

endmodule : l2_cache_control