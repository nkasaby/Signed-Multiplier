# Signed-Multiplier

In this project we implemented an 8-bit signed sequential multiplier which utilizes the shift and add algorithm. This multiplier mimics how multiplication is performed on paper and displays the signed results in decimal on the FPGA’s 7-segment display. Our design process progressed systematically through three main stages which were: designing the datapath (block diagram), creating and simulating a logisim implementation, and writing verilog code for final FPGA implementation. 

## The Design
### Stage I

The datapath consists primarily of five parts:

- **Unsigned Multiplier**

This sub-structure is enabled by a push-down multiplication button and takes in the 8 bit signed multiplier and multiplicand. The multiplier converts them to unsigned and then carries out unsigned multiplication as covered in our lectures through the shift and add algorithm. Since the greatest magnitude that can be resembled in an 8-bit signed number is 128, the greatest product is 16384 which can be represented by 15 bits and 5 decimal digits. Thus the multiplier outputs a 15-bit product, as well as an additional 1 bit representing the sign of the product (1 negative and 0 positive). The sign bit is assigned based on the signs of the inputs and the output is connected immediately to the display mux without further processing.

- **Button Detectors**

Our system takes in input signals from 3 buttons. The first is the multiplication button which initiates the multiplication. The second and third are the scroll-left and scroll-right buttons which enable scrolling through the outputted decimal digits. Since the FPGA we use operates on a clock with a very high frequency of 100MHz, any press on a mechanical push-button will not only cause initial signal fluctuation due to bouncing, but a single press, no matter how fast, will last for a massive number of clock cycles. Consequently, operations run by our system will be repeated for a very large number of times which may negatively influence the system’s functionality and will definitely taint its efficiency. Thus all of our buttons are attached to a button detector circuit which debounces the input signal and ensures that the signal is 1 for exactly 1 clock cycle per press. The button detectors for the left and right scroll buttons are implemented within their corresponding control unit.

- **Binary To BCD Converter**

After completing the multiplication, we are left with our product’s magnitude as an unsigned 15-bit binary number. For this to be transformed into a decimal number shown on the 7-segment display, every decimal digit (total 5) must be converted into a 4-bit binary-coded decimal (BCD). Our converter achieves this through the famous double dabble algorithm . The algorithm logic and implementation will be discussed in detail in later sections of the report. 

- **Digit Selection Circuit**

Since we only have 4 displays on our FPGA board, and since the left-most is always allocated to display the sign, we can only display a combination of 3 of the 5 digits at a time.  Consequently, scrolling through the 5 digits is a necessity for the practical functionality of the multiplier. This selection is done through three 4x1 multiplexers each selecting 4 bits corresponding to a single decimal digit. The initial output combination is digits 1,2 and 3 (numbered from left to right). Scrolling allows the transitioning between the display of the leftmost 3 digits, middle three digits, and rightmost 3 digits. The determination of the selected digits is done through the selection line of the multiplexers which is generated through the button’s control unit. The control unit takes in input signals from the multiplication button, scroll left button and scroll right button and outputs the selection value corresponding to the desired digit combination.

- **7-Segments Driving Circuit**

The 7 segment display on the FPGA enables the display of one digit on all displays at a time. Thus in order to display 3 digits and a sign, we must rapidly alternate between the FPGA’s display digits and the numbers to be displayed, displaying one decimal digit on one display at a time. This has to be done at a very high frequency so that the human eye cannot detect the alterations and instead sees the 3 digits at the same time without any flickering. Thus we use a multiplexed display to showcase our decimal digits on the FPGA board. Our driving circuit consists of a 2-bit binary counter who’se clock is sourced from a clock divider yielding a high frequency. The counter is attached to a binary decoder and another 4x1 display multiplexer. As the binary counter output alternates rapidly  from 0 up to 3 and back to 0 the decoder output changes enabling the activation of a different digit display per counter output. The multiplexer selection line which is also attached to the counter output also alternated per count selecting a different numerical digit from our product. 

- **BCD To 7 Segments**

Our driving circuit is attached to the BCD to 7 segment decoder where the selected display digit on the FPGA is lit with the corresponding 7-segment LED output for the chosen BCD decimal digit.

_________________

### Stage II

The main logisim circuit consisted of already existing components in logisim-evolution along with black boxes we have made. In this section I will be discussing every blackbox and its function in depth.

- **Unsigned Multiplier**

We made a component or a black box on logisim to carry out the unsigned multiplication of 8 bit numbers. In logisim we created two versions of the multiplier component. The general idea behind this component is that it takes in 2 8 bit numbers; one multiplier and the other is the multiplicand; and finds the two’s complement using a two’s complement blackbox which will be discussed later. It then checks the most significant bit in each number and uses a MUX to select whether the two’s complement will be used (if number is negative; ie, MSB=1) or the actual binary number will be used (if number is positive; ie, MSB=0) by using the MSB as a selection for the MUX. The the multiplier will be shifted the the right using an 8 bit shift register which already exists on logisim-evolution and the multiplicand will be shifted to the left using a 15 bit shift register.Using b0 of the multiplier (after shifting) as a select for the MUX we will decide whether to add 8’b0 into the D flip flop that stores the partial products (if b0=0) or add the partial product + the shifted multiplicand to teh D flip flop (if b0=1). The multiplication process starts by pressing a “Multiply Button'' which is detected via a button detector. The sign of the product is also an output attained by putting the MSB of the two numbers in an XOR gate; if the XOR out is 0, it’s a positive product and if it is 1 then it is a negative product. In the first version which was named “unsignedMultiplier'', the control signals for the shift register enables and loads and the D flop flip’s enable were influenced by the button detector, T-flip flop, a D flip flop and a modulo 8 counter which worked in a way such that the registers would load only when the button is pressed and shift occurs up until 8 shifts have been completed then it stops shifting signaling the end of the multiplication process. The enable of the D flip flop that stores the partial products will also be 0 when 8 shifts have occurred to avoid endless repetition of the multiplication. However, this version was not used and was replaced by another one named “multiplypart2” which got rid of the extra hardware used to generate these control signals and instead used the button detector output as the load control signals for both shift registers and the check of whether multiplication process was done or not was via a NOR gate to check if the shifted multiplier is 0 or not. The inverted output of this NOR gate was used as the shift registers’ enable signals and the non inverted output was the mux select which chooses whether the product is 0 or an actual number.

- **Button detector** 

The button detector consists of a debouncer which is made out of 3 flip flops and a 3 input AND gate that takes in the output of each flip flop, a synchronizer which is made out of 2 flip flops and a rising edge detector which is made out of a D flip flop and a 2 input AND gate that takes in D and ~Q.

- **Button control unit** 

The button control  unit uses a button detector, a lot of gates, and a modulo 3 up-down counter. The button detector detects when the right button is pressed and increments the counter however it makes sure that the button could not shift the number displayed on the 7 segment display more than 3 times. The same thing happens with the left button but the counter decrements instead of increments. 

- **Clock divider**

This component uses a modulo 5 counter and a T-flip flop to make the output frequency 1/10 of the input frequency. We set the frequency of the clock on logisim at 1000Hz and hence used this modulo counter to make the output frequency match the output frequency we’ve been using on the FPGA in the lab which is 100Hz.

- **2’s complement**

This component uses 7 single bit full adders to produce the two’s complement of an 8 bit number. It works by assigning the first bit of the number (LSB) as the first bit in the two’s complement (LSB) then checks if the next bit is a 1 or not using a full adder (that acts as a half adder) which adds b0, b1 and 0. The sum is the second bit of the product. Then the next full adders take in the carry and sum from the previous adders and add the next bit in the number. The way this works is that it keeps on copying the bits of the number to the two’s complement from LSB to MSB until the first 1 then it inverts the bits.

- **S0_circuit,S1_circuit,S2_circuit,S3_circuit**

While researching the double dabble algorithm, we found the truth table for the shift add 3 algorithm and from it we created k-maps to synthesize a circuit for S0,S1,S2,S3 so that we can use them in the Shift Add 3 black box to implement the double dabble algorithm to convert binary to BCD.


![Truth Table](https://github.com/nkasaby/Signed-Multiplier/blob/main/truth%20table.png)















- **Shift and Add 3**
In this circuit we gave it 4 bits as an input and they all go through the S0_circuit, S1_circuit,S2_circuit and S3_circuit and accordingly produce the S0,S1,S2,S3 outputs that we observed in the truth table above. The way this works is that it adds 3 whenever the nibble (4 bit number) is 5 or more.

- **Binary to BCD** 

The Double Dabble technique which is the method we used for converting a binary number to binary-coded decimal (BCD) representation. The way this algorithm works is that it uses a shift register where the binary number is loaded on the right and the BCD nibbles on the left, initially set to zero. It performs left shifts, doubling the value, and adds 3 to a BCD digit if it is 5 or larger, ensuring the nibbles stay within the 0-9 range. This "add 3" rule compensates for the reduced weight of a shifted-out bit, aiming to cause an "early carry" at 10 rather than 16. The process continues until the final binary digit is shifted into the BCD portion of the register. The algorithm guarantees that BCD nibbles only hold valid BCD values. To extract the resulting BCD digits, shift and mask operations are typically employed. The way we implemented it on logism was using the truth table above to create the blackboxes  S0_circuit, S1_circuit,S2_circuit and S3_circuit and used them to synthesize the conditional adder blackbox which is “shift_add_3”. The “binarytoBCD” circuit was made out of 30 shift_add_3 circuits where the first shift_add_3 receives the last 3 bits of the number and a 0, then its first 3 outputs go into another shift_add_3 circuit along with the next bit from the number and so on. Also there was a recognisable pattern such that with every 3 shift_add_3 circuit increase the number of shift_add_3 circuit in the row.

- **Main**

The circuit takes in 6 inputs which are the multiply button to signal the beginning of the multiplication, two 8 bit numbers which are the multiplier and the multiplicand, right button and left button to scroll through the digits of the numbers to be displayed on the 7segment display and a clock. The we used the multiplypart2 blackbox to complete the multiplication as explained in the unsigned multiplication section. This will output the sign of the product, turn on a LED when the multiplication is over and the product of the multiplication. The product is then passed to the binarytoBCD blackbox which converts the product from a binary number to a decimal number consisting of 5 digits. Then we use 3 2x1 multiplexers to choose the possible 3 digit combinations that we can get and one 2x1 multiplexer for the sign. We also used the button control unit to control the how much you can scroll when you press on the right and left buttons. The output of this blackbox is used as the select lines for the previously mentioned 3 2x1 multiplexers to determine which combination to show on the 7seg display. We also used a clock divider to lower the frequency for the 7 segment display so that the numbers would appear to be contant. This clock divider is connected to a 2 bit counter which  is used as a selection life for a 4x1 multiplexer that takes in the outputs of the previous 4 2x1 multiplexers as inputs. The counter output is also an inout for a 2x4 decoder alongside a constant 1. We used the built in 7segment display units in logism to simulate the 7segment display. We added 4 7 segement display units. The first one (on the left) represents the sign only, so it’s either off when the product is positive or shows a minus sign when the product is negative. The other 3 7segment display units are controlled via a 2x1 mux with a as one input which turns it off and the output of the 4x1 multiplexer as the other input and the decoder is the selection line of these multiplexers.

_________________

### Stage III

In this stage, we used the circuits we created in logisim as a basis for the modules we'd create in Verilog. Some modules, including all the components of the button detector, the clock divider and the seven segment display, were already made and tested in the lab and I recycled them in our project with small modifications. The biggest modules that were created from scratch were the multiplier, the binary to BCD and the main module. 

#### Utility Modules:
- [***synchronizer***](https://github.com/nkasaby/Signed-Multiplier/blob/main/synchronizer.v)

This module essentially mimics a D-flip flop as it receives a user given input and the output changes along with the input. This is done using an always block triggered by the positive edge of the clock and two nonblocking assignments inside the always block. This module reduces the possibility of metastability due to the changing of input inside the t<sub>su</sub> and t<sub>hold</sub>.

- [***debouncer***](https://github.com/nkasaby/Signed-Multiplier/blob/main/debouncer.v)

This module is needed due to the fact that the mechanical push button, the switch may bounce back and forth until it settles to the value it's supposed to be. This bouncing usually settles within 20ms, therefore we use three D-flip flops (3 non blocking assignments) that receive a clock of 100MHz and will only output 1 when all three flip flops are 1.

- [***rising_edge***](https://github.com/nkasaby/Signed-Multiplier/blob/main/rising_edge.v)

This is an FSM that generates one tick when the input changes from 0 to 1. It has three states, A is when no 1s have been received, B is when one 1 is received and C is when any other 1 is received. The output will only be one in state B, which will make sure the push of the button will only produce 1 for one clock cycle. 

- [***n_bit_counter***](https://github.com/nkasaby/Signed-Multiplier/blob/main/n_bit_counter.v)

This is a parameterized module that will count up or down when the enable is on. It is triggered by the positive edge of the clock and if load is 1, it will load 0, otherwise it will check the up_down flag and add or subtract to the current value based on the result. The parameter modulo will limit the counter to modulo - 1 and the parameter n will decide the number of bits the number will be represented with. 

- [***clock_divider***](https://github.com/nkasaby/Signed-Multiplier/blob/main/clock_divider.v)

This makes an instance of  the counter module to count up to the required frequency (a parameter) using the clock input and then this counter will control the output clock. This method give us clock out to have a f<sub>out</sub> =  f<sub>in</sub> / 2*freq 
	
- [***button_detector***](https://github.com/nkasaby/Signed-Multiplier/blob/main/button_detector.v)

This module brings together the previous modules, synchronizer, debouncer and rising_edge, so that the mechanical button can correctly be detected, it uses the clk_out from the clock divider with frequency of 100Hz. We did this because the built in clock was too fast and the buttons were being detected incorrectly and this raised a few issues with our next modules. 

- [***button_CU***](https://github.com/nkasaby/Signed-Multiplier/blob/main/button_CU.v)

This is an FSM that will detect when the left, right and middle (multiply) buttons are detected using the previously mentioned button detector. It will then move through three different states based on which button is pressed and will decide which three digits will be displayed on the 7 segment. This module was changed from the circuit we showed in the logisim implementation as it was easier to trace through the code using FSM. We experienced a large bump in the module during testing as it seemed as though one state was being skipped over, which should have been impossible, however, after some debugging, we were able to trace the issue back to the button detector and not this module. 

- [***dff_15bit***](https://github.com/nkasaby/Signed-Multiplier/blob/main/dff_15bit.v)

This is a 15 bit load register that will store the partial product in the multiplier module, written exactly as I would write a module for a D-flip flop except the input and output are 15 bits. 

- [***n_bit_shifter***](https://github.com/nkasaby/Signed-Multiplier/blob/main/n_bit_shifter.v)

This module will receive an input to load the register and then will check the left_reihht flag to check which way it will shift, then, using concatenation, it will shift accordingly. This module is parametrized and can shift any given number of n bits. 

#### Main Modules:
- [***bin_to_BCD***](https://github.com/nkasaby/Signed-Multiplier/blob/main/bin_to_BCD.v)

Creating this module on Verilog was infinitely easier than drawing it on logisim. Using a simple for loop, the module will go through the given 15 bit input and check every byte of the input. If the number is greater than 5 then the number 3 will be added to that byte. After all the checks are done, the number is shifted one place to the left and the LSB is loaded with the bit we are currently looping over. This is the double dabble algorithm.  This module is essential as our 7 segment display module will only receive a four bit binary number, therefore it is acting as a translator between our multiplier output and our 7 segment input. 

- [***signed_seq_mult***](https://github.com/nkasaby/Signed-Multiplier/blob/main/signed_seq_mult.v)

This is the module that uses the shift and add algorithm we discussed in the lecture. Using the MSB of the multiplicand and multiplier we will store their positive values using two's complement in new wires and using the XOR gate we can get the sign for our product. When we detect the multiply button using the button detector module the shift registers will begin shifting the positive values of the multiplier and multiplicand. While this happens, if the LSB of the right shifted value is 1, the left shifted value of the multiplicand will be added to the partial product which is stored in an instantiation of dff_15bit. A flag called shift will continue to check the right shifted value of the multiplier. Once that value reaches zero, the flag will end the shifting and the product will be sent as the output

- [***seven_segment***](https://github.com/nkasaby/Signed-Multiplier/blob/main/seven_segment.v)

This module will receive an enable signal to decide which of the four 7 segments will be enabled and this is generated using the button_CU module. The leftmost 7seg will always display the sign whereas the last 3 will show the number and as it shifts. Using a case statement, the module will check for which number it has received and display it using the7 bit codes designed. If the number given is 10 then the 7 segment will display a minus sign, and if any number greater than that is given, the display will be turned off. Seeing as there is no way to show a plus sign on a 7 seg, any positive number will have no sign shown. 

- [***main***](https://github.com/nkasaby/Signed-Multiplier/blob/main/main.v)

This is our top module that brings all the rest of the modules together. It will detect the multiply button, then produce a clk_out of 100 Hz using the clock_divider. A 2 bit modulo 4 counter is then created, taking in the clk_out to produce a select that will decide the digit the seven segment should display. Consequently, an instantiation of the multiplier is created and a product is formed. This product is passed to the binary to BCD module and will return 20 bits containing each of the 5 digits separated into 4 bits each which can then be passed into the seven segments to be displayed. The button_CU will then return the select that will decide where each digit will appear and the seven_segment module will receive all this information to correctly display the final product. The use of the clock_divider ensures that the seven segment looks stable and non-flickering. 

## Implementation Issues

We only faced one issue in our final implementation which is the fact that the LED on the FPGA that signals the end of the multiplication is always in due to the high clock frequency of the FPGA which does not make the LED seem visibly off when multiplication is still ongoing.

## Validation Activities

During the initial steps of creating the modules, I used the validate feature in cloud.v to validate the syntax of my code. Next, when all the modules were written and the syntax was sound, we created testbenches for the modules we weren't sure were fully functional. Finally, after creating the constraints we were able to debug and test using the FPGA. This was a lengthy process that required a lot of focus as there had been multiple small logic errors in a lot of the modules, however, after nine hours of sitting in the digital lab we were able to fix most of the main issues. 

## Contribution

As always, this project was a group effort and no team member was left to take the majority of the work. Mariam thought of the datapath and Nour implemented it on draw.io for the first milestone. Then for the second milestone mariam implemented the binary_to_BCD circuit using the double dabble algorithm while Nour implemented the rest of the circuit components which were discussed in the report above in Stage II. Nadine created the initial Verilog modules. Then we all sat in the digital lab to fix the bugs in our initial implementation till the code and the 7seg display worked the way we want it to.

