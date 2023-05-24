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
In this circuit we gave it 4 bits as an input and they all go through the S0_circuit, S1_circuit,S2_circuit and S3_circuit and accordingly produce the S0,S1,S2,S3 outputs that we observed in the truth table above.

**Binary to BCD** 

**Main**

The circuit takes in 6 inputs which are the multiply button to signal the beginning of the multiplication, two 8 bit numbers which are the multiplier and the multiplicand, right button and left button to scroll through the digits of the numbers to be displayed on the 7segment display and a clock. The we used the multiplypart2 blackbox to complete the multiplication as explained in the [unsigned multiplication] section. This will output the sign of the product, turn on a LED when the multiplication is over and the product of the multiplication. The product is then passed to the binarytoBCD blackbox which converts the product from a binary number to a decimal number consisting of 5 digits. Then we use 3 2x1 multiplexers to choose the possible 3 digit combinations that we can get and one 2x1 multiplexer for the sign. We also used the button control unit to control the how much you can scroll when you press on the right and left buttons. The output of this blackbox is used as the select lines for the previously mentioned 3 2x1 multiplexers to determine which combination to show on the 7seg display. We also used a clock divider to lower the frequency for the 7 segment display so that the numbers would appear to be contant. This clock divider is connected to a 2 bit counter which  is used as a selection life for a 4x1 multiplexer that takes in the outputs of the previous 4 2x1 multiplexers as inputs. The counter output is also an inout for a 2x4 decoder alongside a constant 1. We used the built in 7segment display units in logism to simulate the 7segment display. We added 4 7 segement display units. The first one (on the left) represents the sign only, so it’s either off when the product is positive or shows a minus sign when the product is negative. The other 3 7segment display units are controlled via a 2x1 mux with a as one input which turns it off and the output of the 4x1 multiplexer as the other input and the decoder is the selection line of these multiplexers.

_________________

### Stage III
