# Lab 1 Exercise Report

## Thought Process 
### 1. **Green LED Behavior Part**
| LED        | Meaning when lightened | Logic Element  |
|:------------- |:------------- | :-----:|
| Green LED 0 | switches 7 down to 0 are all turned ON | AND |
| Green LED 1 | at least one of switches 7 down to 0 is turned ON | OR |
| Green LED 2 | switches 15 down to 8 are all turned OFF | NOR |
| Green LED 3 | at least one of switches 15 down to 8 is turned OFF | NAND |
| Green LED 4 | the number of switches from group 15 down to 0 that are turned ON is odd | XOR |
| Green LED [8:5] | show the corresponding position of the least significant switch that is turned OFF, if all of them are ON, show 0000 | MUX |
### 2. **Counter Part**
**Requirements:**
1. Stop at 00/59 and keep the value until the stop/start button is pressed.
2. Flip the counting direction when at 00/59.
3. Counter should start from 00 and counting up at the beginning.

**Thoughts:**
* We set a 1-bit variable called `is_count_up` to control the counting direction (1: count up, 0: count down). When the reset is on, the `counter` will be set to 0 and the `is_count_up` will be 1.
* The three debounce buttons will be used to stop/start counting `stop_count` and control the counting direction `is_count_up` respectively.
* In terms of the edge case of 00/59, we try to set the process (two if statements) of the case when the counter reaches 00/59 inside the counter flip-flop, but an error is thrown due to the overdriven signals of `stop_count` and `is_count_up`. Therefore, we put it inside the button-event flip-flop instead to avoid this issue. For the two if statements, the value of `stop_count` will be set to 1 automatically and `is_count_up` will be flipped when reaches 00/59 at corresponding counting direction to meet requirement 1&2. The input of the debounce button 1 and 2 during 00/59 period will be ignored since the `is_count_up` value will be overwritten by the process.

### 3.**Testing:**
Inside the test branch, we set up different possible combinations of switch and button events, and get the expected result.
