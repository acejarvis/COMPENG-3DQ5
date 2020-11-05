### Exercise 2

Modify the built-in self-test (BIST) engine from __experiment 4__ as follows. To verify all the 2<sup>18</sup> (or 256k) locations of the external SRAM, two sessions of writes and reads will be performed: the first one for the first 2<sup>17</sup> (or 128k) locations and the second one for the last 128k locations, as explained below.

In the first session, the first 128k locations will be verified by first writing the value of the 16 least significant bits of the address (as done for the in-lab experiment). While writing the data during the first session, the address lines must change in the _increasing_ order (from location 0 up to location 128k - 1). Then, the first 128k locations will be read and compared against their expected values to verify their content. When reading the data during the first session the address lines must change in the _increasing_ order (from location 0 up to location 128k - 1).

After the first session is done, the BIST engine will perform the same action for the last 128k locations during the second session. Note, however, unlike for the first 128k locations, when writing data in the last 128k locations the address lines must change in the _decreasing_ order (from location 256k – 1 down to location 128k). Then, the last 128k locations will be read and compared against their expected values to verify their content. Also, unlike for the first session, when reading during the second session the address lines must change in the _decreasing_ order (from location 256k – 1 down to location 128k).

It is important to note that in each of the two sessions, every location must be written exactly once; also, every location must be read and checked exactly once.

Submit your sources and in your report write approx half-a-page (but not more than full-page) that describes your reasoning. Your sources should follow the directory structure from the in-lab experiments (already set-up for you in the `exercise2` folder); note, your report (in `.pdf`, `.txt` or `.md` format) should be included in the `exercise2/doc` sub-folder. Note also, your design must pass compilation in Quartus before you simulate it and you write the report.

Your submission is due 14 hours before your next lab session. Late submissions will be penalized.

