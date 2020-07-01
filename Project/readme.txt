
******ENSE 352 Fall 2019 Semester Project******

Game Name: 	"Whack-a-Mole"
Student Name: 	Jeremy Cross
Student ID: 	200319513

******INDEX******

1.0 Project Description
2.0 Game Instructions
2.1 Turning on the Game
2.2 Waiting for the Player
2.3 Game Mode
2.4 Lose State
2.5 Win State
3.0 Implementation Problems
4.0 Future Expansion
4.1 Multiple LEDs
4.2 Scoring System
4.3 More Levels
5.0 configuration Parameters
5.1 Starting Wait Time
5.2 Delay Times
5.3 Level Amount


****** 1.0 Project Description ******

This game is based on the "whack-a-mole" arcade game where a player will hit a series of moles that
pop up within a set time limit. As the levels increase the time to hit the moles decreases. If the
player is unable to hit all the moles within a given time limit, the player loses.

****** 2.0 Game Instructions ******

Phases:

****** 2.1 Turning on the Game ******

In this phase the player can reset the game by pressing the reset button.

****** 2.2 Waiting for the Player ******

When the game starts, the game waits in an idle state where all LEDs are in an ON configuration.
In this idle state the game is waiting for player input. By pressing any of the Switches the LEDs
will light up in a flow sequence. This pattern will happen twice to prepare player for the first 
level of the game.

****** 2.3 Game Mode ******

Once the start up sequence is complete, the game will begin on level 1. There are 15 levels to this
game. Through each of the 15 levels the player is required to press the corresponding switch to turn
off the lit up LED. The first LED Thats lit up on the first level is always the same, but the LED
thats lit up in every other level is randomized. There are two outcomes where the player can lose. 
If the player fails press the correct switch within the set time limit, the player loses. If the 
player presses the incorrect switch the player will also lose. The player can only win the game by 
successfully pressing the correct switch and turning off the LEDs for each of the 15 levels. A list 
representing which switch corresponds to which LED is shown below.

	SW2--->LED1
	SW3--->LED2
	SW4--->LED3
	SW5--->LED4

****** 2.4 Lose State ******

If the player presses the incorrect switch or fails the enter the correct switch within the time
limit the lose state will occur. When the player loses, the game will turn off any active LEDs and
display the level the player lost on in binary. Once the level is finished being displayed, the
game will reset itself back to the being idle state and await player input to play again. The
binary patterns for each of the levels are listed below.

			LED1	LED2	LED3	LED4
	Level 1		OFF	OFF	OFF	ON
	Level 2		OFF	OFF	ON	OFF
	Level 3		OFF	OFF	ON	ON
	Level 4		OFF	ON	OFF	OFF
	Level 5		OFF	ON	OFF	ON
	Level 6		OFF	ON	ON	OFF
	Level 7		OFF	ON	ON	ON
	Level 8		ON	OFF	OFF	OFF
	Level 9		ON	OFF	OFF	ON
	Level 10	ON	OFF	ON	OFF
	Level 11	ON	OFF	ON	ON
	Level 12	ON	ON	OFF	OFF
	Level 13	ON	ON	OFF	ON
	Level 14	ON	ON	ON	OFF
	Level 15	ON	ON	ON	ON

****** 2.5 Win State ******

If the player successfully turns off all of the LEDs for each of the levels, the player will be
notified that they won by all the LEDs blinking 5 times. Once the LEDs finish the blinking
sequence the game will reset back to the idle state and await player input to play again.

****** 3.0 Implementation Problems ******

- decreasing game timer for levels

I was unable to implement a decreasing game timer because I ran out of registers to use. I had
thought about using comparisons for different levels based on the level counter, however when I
tryed to implement this I recieved strang errors on different lines throughout my code.
Theoretically, without the errors I would just continue to reduce the counter number with each
increasing level.

****** 4.0 Future Expansion ******

****** 4.1 Mulitple LEDs ******

For future additions, multiple LEDs could come on during each level any where from 1 LED to 4
LEDs. The player would then have to press multiple switchs corresponding to each of the LEDs
and turn them all off before the time expires.

****** 4.2 Scoring System ******

A scoring system could be implemented where the player could earn points based on how fast
they complete a level, how many levels they completed and how many LEDs they have turned 
off. This would work best with the multiple LED feature implemented so the scores would
constantly be different. With just one LED lit up at a time the player would be awarded just
the same number of points per level. The point total at the end of the game could be shown
on the LED display

****** 4.3 More Levels ******

More levels could be incorperated into the game where the level cap could just be increased
or there could be an infinite number of levels where the player just plays until they lose.
When the game is finished the level number could be displayed either before or after the
score.

****** 5.0 Configuration Parameters ******

****** 5.1 Starting Wait Time ******

The wait time at the begininning of the game during the idle state is completely determined
by the player. The game will not start until the player presses one of the four switches.
This state is also used to create a seed value for the randomization of the LEDs during
game mode state.

****** 5.2 Delay Times ******

The delay time for different points of the program can be modifiyed in the code, however
I adjusted the speed to values that I found appropriate in most places. The delays can be 
modified to each users specific liking.

****** 5.3 Level Amount ******

The levels of the game can also be adjusted within the code as well, however there is no code
in place to account for any levels of the game past 15. So there would be no lose state conditions
showing an LED pattern for the level that the player lost on.








