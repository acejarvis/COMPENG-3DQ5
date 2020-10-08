### Take-home exercise

Modify **experiment 5** as follows.

Behavior of the green LEDs should be changed as follows:

- Green LED 0 is lightened only if switches 7 down to 0 are all turned ON, i.e., high position or logic high;
- Green LED 1 is lightened only if at least one of switches 7 down to 0 is turned ON;
- Green LED 2 is lightened only if switches 15 down to 8 are all turned OFF;
- Green LED 3 is lightened only if at least one of switches 15 down to 8 is turned OFF;
- Green LED 4 is lightened only if the number of switches from group 15 down to 0 that are turned ON is an odd number;
- Green LEDs 8 down to 5 display the position (or index) of the least significant switch that is turned OFF from group 15 down to 0; note, if none of the switches from this group are turned OFF then you can display an arbitray value of your choice on this group of LEDs;

- Only the two least significant 7-segment displays are used and they display the counter value in binary-coded decimal (BCD) format; to accomodate for this change the counter circuit must be modified to update every second in 2-digit BCD format within the range 00 to 59;
- When the counter is active and it is in the range 01 to 58 (inclusive), the functionality of push-buttons 0, 1 and 2 should be exactly the same as specified for the in-lab **experiment 5**;
- When the counter reaches either 00 or 59 the following should occur:
- - When counting up and 59 has been reached, the counter should automatically stop and the activity on push-buttons 1 and 2 will be ignored; the counter will be restarted only when push-button 0 is pressed, at which time the counting direction will be automatically changed to count down;
- - When counting down and 00 has been reached, the counter should automatically stop and the activity on push-buttons 1 and 2 will be ignored; the counter will be restarted only when push-button 0 is pressed, at which time the counting direction will be automatically changed to count up;
- On power-up assume the counter is active in state 00, and the counting direction us up.

Submit your sources and in your report write approx half-a-page (but not more than full page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise` folder; note, your report should be included in the `exercise/doc` sub-folder.
