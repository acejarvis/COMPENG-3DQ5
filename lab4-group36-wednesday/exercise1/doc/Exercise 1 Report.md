# Lab 4 Exercise Report

### **Requirements**
- Implement the following four formulas in two DP-RAMs. (for every k from 0 to 255)
    - Y [2k]   = W [2k]   - X [2k+1]

    - Y [2k+1] = W [2k+1] + X [2k]

    - Z [2k]   = W [2k+1] + X [2k+1]

    - Z [2k+1] = W [2k]   - X [2k]

- Each Y[i] and Z[i] will overwrite the corresponding W[i] and X[i].

### **Thoughts**
According to the given formulas, there will be 4 variables (W, X, Y, Z) and 2 adjacent indexes(2k, 2k+1) involved in one period. Since the two DP-RAMs only have 4 ports that can be used at the same time, we decided to use the following design:

- The entire process for every k will be programed into a state machine of 4 states: 
    | State | Description |
    | ----------- | ----------- |
    | S_IDLE | Initialize the read/write addresses, will be run only once. |
    | S_CALCULATE | Enable write access to all the 4 ports and do the calculation using the above 4 formulas. |
    | S_WRITE | Load the calculation result from cache registers to RAMs. |
    | S_READ | disable write access to all the ports (convert write ports to read ports) and update the 4 read/write addresses to the next period until addresses reach the end. The new period of values will be read in this state. |
- To realize the design and the formulas, we enable all the 4 ports on the two DP-RAMs and use the adjacent addresses to represent 2k and 2k+1. In this case, we defined **read_write_address_a[1:0]** and **read_write_address_b[1:0]**, **a[0]** for W[2k], **a[1]** for X[2k], **b[0]** for W[2k+1] and **b[1]** for X[2k+1] correspondingly. And we use the same naming rule for **write_data_a [1:0]**, **write_data_b [1:0]**, **read_data_a [1:0]** and **read_data_b [1:0]** as well.
 - You might also notice that we use cache to store the calculation results, this is because we enable all the ports at the same time for the same read or write access. In this case, we need to store the results somewhere else temporarily and to be used by the write access after turn on the write and turn off the read for all the ports. For this purpose, we defined **cache_data_a [1:0]** and **cache_data_b [1:0]**, using the same amount of bits as the RAM port registers.