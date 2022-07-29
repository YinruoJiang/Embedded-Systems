# Embedded-Systems

# Objecitves:
Interact with the LEDs directly using memory

Implement and demonstrate the use of the watchdog

Use the button as an interrupt

Structure your code

# Tasks:
Create a new item called _xxWatch, where xx are replaced by your initials, in the menu (the one we normally access with minicom) to demonstrate that the hardware watchdog works. 
Requirements:
Initialize and start the watchdog from your C hook code as shown in the lab

Experiment with the prescaler and reload values to determine the watchdog duration. Make this duration configurable in the call to your C code.

This function will blink all 8 LEDs on and off at once, forever, using direct memory access as shown in your recent lab

If the user button has not been pressed, refresh the watchdog appropriately

After the user button has been pressed, don’t refresh the watchdog anymore, but continue blinking the LEDs. A properly configured watchdog will result in the board rebooting after the watchdog timer has expired.
