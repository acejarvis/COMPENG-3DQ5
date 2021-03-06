/*
Copyright by Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

class driver;
  
	virtual board_intf vif;
	mailbox gen2drv;

	function new(virtual board_intf vif, mailbox gen2drv);
		this.vif = vif;
		this.gen2drv = gen2drv;
	endfunction

	task reset();
	begin
		vif.switch[17:0] = 18'd0;
	end
	endtask

	task main();
		int next_index;
		board_event my_trans;
	begin
		forever begin
			gen2drv.get(my_trans);
			next_index = my_trans.get_index();
			if (my_trans.is_switch_toggle())
				vif.switch[next_index] = ~vif.switch[next_index];
		end
	end
	endtask
  
endclass

