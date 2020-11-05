# Lab 4 Exercise 2 Report

### **Requirements**
- Using two sessions to verify all 2^18 bits inside the ROM.
- The first session is to verify the first 2^17 bits that the addresses are in an increasing order.
- The second session is to verify the last 2^17 bits that the addresses are in a decreasing order.
- Each session will write once, read once and compare once.
### **Thoughts**
- In order to have two sessions instead of only one, we extend the states of *BIST_state* from [2:0] to [3:0] so that it can have 14 states. Then, when the first session is at *S_DELAY_4*, it will not go back to the *S_IDLE*, but to the beginning of the second session called *S_IDLE2* to run an extra session.
- The address in the first session will be initiated to number 0 on the *S-IDLE* state, and increased by 1 on each clock cycle. Then it will be initiated to number 2^18-1 on the *S_IDLE2* state, and decreased by 1 on each clock cycle.
- To check the reading data, we put the register *BIST_expected_data* inside the always_ff in order to change its value corresponding to different sesstions. Firstly, we initiated its value to 0 at one clock cycle before the *S_READ_CYCLE*, which is the *S_DELAY_2* state, so the element at address 0 can be compared on the first clock cycle of the *S_READ_CYCLE* state. Inside the *S_READ_CYCLE* , *S_DELAY_3* and *S_DELAY_4* states, we assign that BIST_expected_data* to be address-1 and compare it with the reading data by using a flag called *BIST_mismatch*. After that, in the second session, because the address is in a decreasing order, we assign the value of expected data with address+1 in order to do the right comparison, and the other steps are the same as in the first session. Finally, after all 2^18 locations been checked, the state will go back to *S_IDLE*.