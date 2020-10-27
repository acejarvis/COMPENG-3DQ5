# Lab 3 Report

### **Requirements & Thoughts**
**1. Display the first 15 keys in the same row.(nonnumerical: space)**

- In order to only print the numerical key, we identify the character address of the numerical key that matches the corresponding PS2 code using switches cases and stores it in the 6-bit `PS2_character_address` register. Because there are in total 15 keys needed to be displayed, we also assign 15 6-bit data shift registers called `PS2_reg` to shift and store the 15 character addresses, which will be used in the VGA display part to actually print the characters in the same row.

**2. display the most appeared numerical key and the counter of it to the second line.(If counter is more than 9, display BCD values)**
- At the beginning, we assign a 5-bit register called `data_count` to check how many PS2 codes are loaded. Then, 10 4-bit registers `key_pressed` will record how many times each key(from 0 to 9) is pressed. While the PS2 code is loading, the switch cases will go to the corresponding conditions to count the pressed times and stored the count to its `key_pressed` register. 

- Also, we assign 2 4-bit registers called `max_pressed_count` and `max_pressed` to do comparison and record the max key pressed count and the largest key. In order to deal with this, when data_count reaches 15 times, we firstly do the comparison between `max_pressed_count` and `key_pressed`(from 0 to 9 in order to print the largest number), and when the `key_pressed` is greater than the `max_pressed_count`, the value of `max_pressed_count` will be updated by the pressed times of that key and the `max_pressed` register will record the value of that key in decimal. After the comparison is done, the `max_pressed_count` records the counter of the most pressed key and the `max_pressed` recorded which key it is. 

- For displaying `max_pressed_count` and `max_pressed` values in the format of "KEY `max_pressed` PRESSED `max_pressed_count` TIMES", we  assign a 6-bit (1 BCD value 0-9) register `max_pressed_address` and a 12-bit (2 BCD value 00-15) register `max_pressed_count_address` to translate the corresponding 8x8 character addresses from `max_pressed_count` and `max_pressed` using switch cases. In any case if the `max_pressed_count` is less then 10, the counter display will only occupy 1 character position instead of 2 and the following characters will be left-shifted 1 character position as well. Finally, if the `max_pressed_count` is zero, which means that there is no numerical key pressed, the frame will display "NO NUM KEYS PRESSED".

**3. Resources usage**
- There are 235 registers been used in total and 162 of them are used in "experiment4" file.
- Without any changes, there are 82 registers at the beginning. Therefore, we totally add 80 registers inside.
- In part 1:
   1. 15 6-bit `PS2_reg` data shift registers to record the pressed key's character address directly.
   2. Two 6-bit registers called `PS2_character_address` and `character_address` to assign and print those 15 keys. The reason why we use two separate address register is to avoid overdriven signals.
- In part 2:
  1. 5-bit `data_count`
  2. 10 4-bit `key_pressed` to record times each key pressed.
  3. 2 4-bit registers `max_pressed_count` and `max_pressed` to record the maximum number and the counter of it.
  4. 6-bit register `max_pressed_address`.
  5. 12-bit register `max_pressed_count_address` to display the BCD values.

Finally, we also check the switch cases and if statement to check whether they need registers. The answer is yes, and the usage they needed depends on the registers in their conditions.