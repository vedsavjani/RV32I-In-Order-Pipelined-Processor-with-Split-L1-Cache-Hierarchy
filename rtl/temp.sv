always @(posedge clock)
begin	
	case (currentState)	
		miss: begin
			// one of the ways is invalid -- no need to evict
			if(~valid1[address[`INDEX]])
			begin
				mem1[address[`INDEX]] <= mq;
				tag1[address[`INDEX]] <= address[`TAG];
				dirty1[address[`INDEX]] <= 0;
				valid1[address[`INDEX]] <= 1;
			end

			else if(~valid2[address[`INDEX]])
			begin
				mem2[address[`INDEX]] <= mq;
				tag2[address[`INDEX]] <= address[`TAG];
				dirty2[address[`INDEX]] <= 0;
				valid2[address[`INDEX]] <= 1;
			end

			else if(~valid3[address[`INDEX]])
			begin
				mem3[address[`INDEX]] <= mq;
				tag3[address[`INDEX]] <= address[`TAG];
				dirty3[address[`INDEX]] <= 0;
				valid3[address[`INDEX]] <= 1;
			end

			else if(~valid4[address[`INDEX]])
			begin
				mem4[address[`INDEX]] <= mq;
				tag4[address[`INDEX]] <= address[`TAG];
				dirty4[address[`INDEX]] <= 0;
				valid4[address[`INDEX]] <= 1;
			end
			
			// way 1 is LRU
			else if(lru1[address[`INDEX]] == 3)
			begin
				// dirty block writeback
				if(dirty1[address[`INDEX]] == 1)
				begin
					_mwraddress <= {tag1[address[`INDEX]],address[`INDEX]}; 
					_mwren <= 1;
					_mdout <= mem1[address[`INDEX]];
				end
				mem1[address[`INDEX]] <= mq;
				tag1[address[`INDEX]] <= address[`TAG];
				dirty1[address[`INDEX]] <= 0;
				valid1[address[`INDEX]] <= 1;
			end
			
			// way 2 is LRU
			else if(lru2[address[`INDEX]] == 3)
			begin
				// dirty block writeback
				if(dirty2[address[`INDEX]] == 1)
				begin
					_mwraddress <= {tag2[address[`INDEX]],address[`INDEX]};  
					_mwren <= 1;
					_mdout <= mem2[address[`INDEX]];
				end
				mem2[address[`INDEX]] <= mq;
				tag2[address[`INDEX]] <= address[`TAG];
				dirty2[address[`INDEX]] <= 0;
				valid2[address[`INDEX]] <= 1;
			end
			
			// way 3 is LRU
			else if(lru3[address[`INDEX]] == 3)
			begin
				// dirty block writeback
				if(dirty3[address[`INDEX]] == 1)
				begin
					_mwraddress <= {tag3[address[`INDEX]],address[`INDEX]};  
					_mwren <= 1;
					_mdout <= mem3[address[`INDEX]];
				end
				mem3[address[`INDEX]] <= mq;
				tag3[address[`INDEX]] <= address[`TAG];
				dirty3[address[`INDEX]] <= 0;
				valid3[address[`INDEX]] <= 1;
			end
			
			// way 4 is LRU
			else if(lru4[address[`INDEX]] == 3)
			begin
				// dirty block writeback
				if(dirty4[address[`INDEX]] == 1)
				begin
					_mwraddress <= {tag4[address[`INDEX]],address[`INDEX]};  
					_mwren <= 1;
					_mdout <= mem4[address[`INDEX]];
				end
				mem4[address[`INDEX]] <= mq;
				tag4[address[`INDEX]] <= address[`TAG];
				dirty4[address[`INDEX]] <= 0;
				valid4[address[`INDEX]] <= 1;
			end

			currentState <= idle;
		end
	endcase

end
