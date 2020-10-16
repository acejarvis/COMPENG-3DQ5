# Lab 2 Report

### **Requirements & Thoughts**


1. Upper memory half should store the LCD codes for upper-case characters.
- We checked the memory file(mif), and updated its lower part with upper-case alphabet characters.

2. PS/2 left-shift key set the mode to upper-case and the right-shift key reset to lower case. The last key typed between two characters will be considered as input.
- We created a flag called upper_case to set the uppercase or lowercase, and used an extra flip flop to check the PS2 shift keys. This is to avoid the shift code being put into the 16 data registers. Then, We extended `data_reg` 1 more bit in order to store uppercase state in the MSB for that character so that the ROM will output the corresponding LCD_code only depends on the entire `data_reg` value. In the IDLE state, it will also ignore left shift and right shift keys when assign the `upper_case` + `PS2_code` to `data_reg`.

3. Type first character in line 0 and display immediately and then type the next 16 characters and show together in line 1
- Firstly, we defined two registers, `repeat_counter` to count the times of repetition and `first_character` to store the PS2 code of the 1 character in line 1. While the `PS2_code` is loaded into the `data_reg`, it will be compared with the first character and if they are equivalent, the `repeat_counter` will plus 1. Only alphabet PS2 codes will be considered. After that, we used a register called `LCD_position_limit` to limit that the first line can only display one character. As a result, if it reaches the limit, it will move to the second line. Then, at the beginning of the IDLE state, we will check if it is in the first line after edge detect. If yes, the register called first character will record the value of that `PS2_code` and issue the LCD instruction immediately. If no, after all the 15 `PS2_code` are loaded, the LCD code will be presented immediately in the bottom line.

4. After all the 17 characters being typed, 7-segment display 0 should show how many times the first character repeated in the bottom line. (Only applies to alphabet, uppercase does not matter)
- Right now we already had the `repeat_counter` value. As a result, we created a variable called repeat_counter_display to record the last update of the `repeat_counter` within the cycle, and convert it into 7 segment display. After displaying, the value of repeat counter and display will be reset to zero to wait for next cyle of data. We used a flag`counter_display_on` to check if it need to turn ON/OFF the 7 segment display. After all 16 characters are displayed, `counter_display_on` will be on and then turned off once the next first character is typed. The
actual implement of turn ON/OFF is done in the assignment of 7 segment display.
