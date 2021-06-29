# ALU with memory management  



1.Compile
```
iverilog -o test.vvp cpu.v alu.v decode_unit.v mux.v programe_counter_unit.v reg_file.v twoscomplement.v shifters.v tb_cpu.v dmem_cache.v cache.v imem_for_icache.v icache.v
```
2.Run
```
vvp test.vvp
```
3.Open with gtkwave tool
```
gtkwave wavedata.vcd
```


Include files:21

	README.MD
	Timing Diagrams:
		cpu_timing_part1.png
		cpu_timing_part2.png
		cpu_timing_part3.png
	Verilog Files:
		cpu.v ,alu.v ,decode_unit.v ,mux.v ,
		programe_counter_unit.v ,reg_file.v ,twoscomplement.v ,
		shifters.v ,dmem_cache.v ,cache.v
		tb_cpu.v
		imem_for_icache.v ,icache.v
	CO224Assembler.c
	test_program_1.s
	test_program_1.s.machine
	wavedata.vcd
	


