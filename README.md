# <ins>5 Stage MIPS Pipelined Processor Documentation and Behavioural Simulations</ins>

Below are the simulations and the state diagrams I used for designing my 5 Stage MIPS pipeline. All of these simulations were done on Xilinx Vivado and Virtex5 FPGA. 

## Hazard Detection Unit (Without jal and jr instructions)

### Forwarding Unit
For R-type instructions:

<img width="586" height="502" alt="image" src="https://github.com/user-attachments/assets/ca768957-b096-41d5-be22-19f13acd092f" />

<br><br>
For Immediate Instructions:

<img width="586" height="502" alt="image" src="https://github.com/user-attachments/assets/78d2f96c-7420-4e5c-9662-9e355b6ed272" />

### Hazard Detection Unit
State Machine & Flow chart of Hazard Detection Unit without jal and jr: 

<img width="581" height="582" alt="image" src="https://github.com/user-attachments/assets/127671c5-5a76-4606-b900-b2dabd1998af" />

<br><br>
<img width="317" height="426" alt="image" src="https://github.com/user-attachments/assets/68f96083-e648-40aa-9abe-1bdbcbe4adc4" />

## Pipelined Process Behavioural Simulation (WITHOUT jal & jr)

<img width="617" height="200" alt="image" src="https://github.com/user-attachments/assets/fb1fb2ff-0348-40f8-a984-070ac59889bf" />
<br><br>
This is called static branch prediction, in particular, it is the ‘branch always not taken’ prediction. To accommodate this improvement in our existing design, we need to make the following changes:

* When a branch is encountered, do not add a bubble in the pipeline.

* Keep IFwrite and PCwrite signals HIGH to ensure that instruction at PC+4 address is fetched.

* After resolving the branch, if the branch is not taken, then no operation needs to be performed.

* However, if the branch is taken, the pipeline must be flushed and the correct instruction at the branch target address must be fetched at the start of the next cycle and resume normal execution.


### Timing Report

Slack: inf

Source: MEM_WB_MemToReg_reg_rep/C
(rising edge-triggered cell FDCE)

Destination: program_counter_reg[23]_C/D

Path Group: (none)

Path Type: Max at Slow Process Corner

Data Path Delay: 20.043ns (logic 1.957ns (9.764%) route 18.086ns (90.236%))

Logic Levels: 11 (FDCE=1 LUT3=2 LUT4=1 LUT5=3 LUT6=4)

According to the design timing report, the clock period is Tclock = 20.043 ns, where the worst slack is minimum. The frequency is calculated to be fclock = 49.892 MHz.


## Hazard Detection Unit State Diagram (With jal and jr instructions)

<img width="454" height="541" alt="image" src="https://github.com/user-attachments/assets/90859f40-f79d-4c82-a076-8610fd849484" />

## Pipelined Process Behavioural Simulation (WITH jal & jr)

<img width="837" height="328" alt="image" src="https://github.com/user-attachments/assets/0d23e1d7-981c-4ba0-9cce-b854a4f43833" />
<br><br>
The clock rate for this came out to be 114MHz which was more than that without jal and jr instructions implementation (49MHz) in the hazard detection unit. The implementation of jal and jr might have necessitated changes that removed existing bottlenecks in the pipeline, allowing for faster overall operation. The addition of jal and jr instructions may have led to a restructuring of the pipeline that inadvertently optimized the critical path. To make the frequency better, we need to make the critical path faster. This can be made faster by a better and improved VLSI design changes like optimal number of buffers and using wider wires for low resistance.
