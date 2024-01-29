# embedded_systems
 project of multiprocessing systems in integrated circuits course

Data Acquisition Design and Average Value of Samples Taken
Aim The purpose of this project is to design a data acquisition to processes an array of data and by manipulating the input through different circuit designs to output the average of the samples.

Circuits designed with system Verilog include:

1.A synchronizer for asynchronous data sampling

2.Median filter to process the data, store it, sort it and give its median value.

3.Fifo

4.Median circuit that sorts the input and outputs the median result

5.FSM that writes the median input

6.Block Ram: Dual port. It receives data and pass it to the last circuit

7.FSM that reads the values from ram and process it to give the average result

Design description

The asynchronous data sampling requested the design of a synchronizer that uses two D flip flop in series. By doing so we avoid metastable state and the signal can be synchronized.
Second stage is the design of the median filter. In this stage we design a three place FIFO as an array and a combinational circuit that takes these 3 values sort them and outputs the mean value of the three for further process. The design includes two sequential circuits and then the combinational circuit.
The first waits for the data_av_sync signal to start shifting the values. I was trying to make three different registers of 16bit each but this way I could not deal with the combinational part when trying to access each fifo index for sorting and saving. So I made the fifo as an array with addresses and a temporary register to save the value of each fifo. The flow chart below is giving the algorithm idea.
image

The combinational design first checks which register is smaller, then this value is saved in a temporary register and its index also in an array named addr. Vivado did not allowed to have three different always_comb because of multiple driving issues of addr.
The second sequential works as a flag that acknowledge there is a median value ready to the output
Next part is the design of the FSM for writing to the BRAM the median values coming from the median filter. Here we have two states IDLE, WRITE.
IDLE: the machine stays idle with all signals to initial state.
WRITE: checks when the output of the previous stage is giving high we start writing to the address we want in BRAM, concurrently we increase the value of the address up to 8 values and when ready we signal the input of the next FSM to request the addresses from the BRAM.
Within the two FSM’s we have a BRAM made from the Vivado IP catalog. The features after building the BRAM is giving us two cycles portal B read latency which means that we need to have two empty states in our read FSM in order to write the data. The BRAM works in a last in first out order when simulating.

Next module is the FSM for the read from the RAM and calculating the average of the values. Six states are required in this FSM: IDLE, REQUEST, WAITING, WAITING1, RECEIVE, CALCULATE.

IDLE: Same as before
REQUEST: In this state the machine after getting its control input signal high from FSM write, sends an internal signal that connects with output signal addr to request the first address from the RAM. Then waits for two states required from the BRAM to answer.
RECEIVE: After two cycles the value comes from BRAM and is saved in a temporary array. Then it needs 7 counts to give to fill the array and do the calculation in the next state. The count in the RECEIVE state has an extra count before going back to IDLE. This gives time for the next state.
CALCULATE: This state checks that the count is seven which means that all values are in and is doing the calculation of the average in an assign process that shifts the sum by three.
