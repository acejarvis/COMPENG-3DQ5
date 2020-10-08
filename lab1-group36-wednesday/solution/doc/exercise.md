### Take-home exercise

Modify **experiment 5** as follows.

Behavior of the green LEDs should be changed as follows:

- Green LED 0 is lightened only if switches 7 down to 0 are all turned ON, i.e., high position or logic high;
- Green LED 1 is lightened only if at least one of switches 7 down to 0 is turned ON;
- Green LED 2 is lightened only if switches 15 down to 8 are all turned OFF;
- Green LED 3 is lightened only if at least one of switches 15 down to 8 is turned OFF;
- Green LED 4 is lightened only if the number of switches from group 15 down to 0 that are turned ON is an odd number;
- Green LEDs 8 down to 5 display (in binary format, naturally) the position (or index) of the least significant switch that is turned OFF from group 15 down to 0; note, if none of the switches from this group are turned OFF then you can display an arbitray value of your choice on this group of LEDs;

- Only the two least significant 7-segment displays are used and they display the counter value in binary-coded decimal (BCD) format; to accomodate for this change the counter circuit must be modified to update every second in 2-digit BCD format within the range 00 to 59;
- While the counter is changing, i.e, its value is within the 00 to 59 range, the functionality of push-buttons 0, 1 and 2 should be exactly the same as specified for the in the-lab **experiment5**;
- When the end of the range is reached the following should occur. 
- - While counting up, when 59 is reached the counter should automatically stop. At this time, the activity on push-buttons 1 and 2 does not matter and the counter will be restarted only when push-button 0 is pressed again, at which time the counting direction will be automatically changed to count down. 
- - Following the same line of reasoning as above, while counting down when 00 is reached the counter should be frozen and it will be restarted only when pressing push-button 0 again, at which time the counting direction will be automatically changed to count up.

Submit your sources and in your report write approx half-a-page (but not more than full page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise` folder; note, your report should be included in the `exercise/doc` sub-folder.
