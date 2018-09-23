--Protected types: Ada lab part 4

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

use Ada.Calendar;
use Ada.Text_IO;

procedure comm2 is
	subtype Element_Range is Integer range 0..25;
   package Rand_Element is new Ada.Numerics.Discrete_Random(Element_Range);
       
	Message: constant String := "Protected Object";
    	type BufferArray is array (0 .. 9) of Integer;
        -- protected object declaration
	--Message: constant String := "Process communication";	
	Element_Gen: Rand_Element.Generator;	
	protected  buffer is
		-- add entries of protected object here
		procedure Push(Element: in Integer; Blocked: out Boolean);
      	procedure Pop(Element: out Integer; Blocked: out Boolean);
      	entry Stop;
		procedure Set_Should_Stop    (N : in boolean);
             
	private
		Queue_length : Integer := 0;
		Shared_buffer : BufferArray;
		Blocked : Boolean := False;
				
		Queue_Capacity: Integer;
   	    Head: Integer := 0;
    	Tail: Integer := 0;
    	--Queue_Length: Integer := 0;
    	Should_Stop: Boolean := False;	
	
	end buffer;

            -- add local declarations
	task producer is
		-- add task entries
	end producer;

	task consumer is
                -- add task entries
	end consumer;

	protected body buffer is 
              -- add definitions of protected entries here 
		
		
    	
		procedure Push(Element: in Integer; Blocked: out Boolean) is
		begin
			if Queue_Length = Queue_Capacity then
				Blocked := True;
			else
				Queue_Capacity := Shared_buffer'length;
				Shared_buffer(Tail) := Element;
		  		Tail := (Tail + 1) mod Queue_Capacity;
		  		Queue_Length := Queue_Length + 1;
		  		Blocked := False;			
			end if;
		end Push;
		
		procedure Pop(Element: out Integer; Blocked: out Boolean) is
		begin
			if Queue_Length = 0 then
		  		Element := -1;
		  		Blocked := True;
	       else
		  		Element := Shared_buffer(Head);
		  		Head := (Head + 1) mod Queue_Capacity;
		  		Queue_Length := Queue_Length - 1;
		  		Blocked := False;
	       end if;
		end Pop;
		
		entry Stop  when Should_Stop is	
		begin
			Put_Line("Buffer: Received signal to stop, stopping producer first.");
	        --producer.Stop;
	        Should_Stop := True;
		end Stop;

		procedure Set_Should_Stop (N : in boolean)  is
		begin
			Should_Stop := N;
		
		end Set_Should_Stop;
	end buffer;

        task body producer is 
		Message: constant String := "producer executing";
                -- add local declrations of task here  
		Blocked: Boolean := false;		
		Value: Integer;
		--Stop_Flag: Boolean;
	begin
		Value := Rand_Element.Random(Element_Gen);		
		Put_Line(Message);
		loop
	 -- add your task code inside this loop
		select 
			accept buffer.Stop do
				buffer.Set_Should_Stop(True);
			end buffer.Stop;
		else
	    Put_Line("Producer: Pushing...");
	    buffer.Push(Value, Blocked);
	 
	    if not Blocked then
	       Put_Line("Producer: Pushed value:" & Integer'Image(Value));
	       Value := Rand_Element.Random(Element_Gen);
	    else
	       Put_Line("Producer: Blocked, capacity reached");
	    end if;
	    
		end select;
	    --delay Duration(Ada.Numerics.Float_Random.Random(Delay_Gen) * 2.0);
	 
	 
	 exit when buffer.Should_Stop;
      end loop;
      
      Put_Line("Producer: Received signal to stop, stopping.");
   end producer;
   

	task body consumer is 
		Message: constant String := "consumer executing";
                -- add local declrations of task here 
		Blocked: Boolean := false;		
		Value : Integer;
		Sum: Integer := 0;
	begin
		Put_Line(Message);
		Main_Cycle:
	 -- add your task code inside this loop
	loop 
	 Put_Line("Consumer: Popping...");
	 buffer.Pop(Value, Blocked);
	 
	 if not Blocked then
	    Sum := Sum + Value;
	    Put_Line("Consumer: Popped value:" & Integer'Image(Value) & ", Sum:" & Integer'Image(Sum));
	    exit Main_Cycle when Sum > 100;
	 else
	    Put_Line("Consumer: Blocked, queue empty");
	 end if;
	 
	-- delay Duration(Ada.Numerics.Float_Random.Random(Delay_Gen) * 5.0);
      end loop Main_Cycle;
      
      -- add your code to stop executions of other tasks
      Put_Line("Consumer: Total sum:" & Integer'Image(Sum) & ". Stopping buffer.");
      buffer.Stop;
      Put_Line("Consumer: Buffer stopped. Stopping.");
   exception
      when TASKING_ERROR =>
	 Put_Line("Buffer finished before producer");
	 Put_Line("Ending the consumer");
   end consumer;

begin
Put_Line(Message);
   Rand_Element.Reset(Element_Gen);
   --Ada.Numerics.Float_Random.Reset(Delay_Gen);
end comm2;

