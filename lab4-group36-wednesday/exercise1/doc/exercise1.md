### Exercise 1

Modify the design from __experiment 3__ as follows. In the first and the second DP-RAMs there are two different arrays (called W and X respectively) of 8-bit signed integers. Each of these two arrays has 512 elements (initialized the same way as in the lab, i.e., using memory initialization files). Design the circuit that computes two arrays Y and Z defined as follows (for every k from 0 to 255): 

Y [2k]   = W [2k]   - X [2k+1]

Y [2k+1] = W [2k+1] + X [2k]

Z [2k]   = W [2k+1] + X [2k+1]

Z [2k+1] = W [2k]   - X [2k]

Each element Y[i] should overwrite the corresponding element W[i] in the first DP-RAM (for every i from 0 to 511); likewise, each Z[i] should overwrite the X[i] in location i in the second DP-RAM. As for the in-lab experiment, if the arithmetic overflow occurs, as a direct consequence of the additions/subtractions, it is not necessary to detect it, i.e., keep the 8 least significant bits of the result. The above calculations should be implemented in as few clock cycles as it can be facilitated by the two DP-RAMs.

Submit your sources and in your report write approx half-a-page (but not more than full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise1` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise1/doc` sub-folder. Note also, your design must pass compilation in Quartus before you simulate it and you write the report.

Your submission is due 14 hours before your next lab session. Late submissions will be penalized.

