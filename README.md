Nexys A7 Accelerometer-Based Control System

Overview: This project implements an accelerometer-based control system for the Nexys A7 FPGA board. The system uses the onboard accelerometer to control a white ball displayed on a VGA monitor. This code is provided for educational purposes to demonstrate SPI communication, accelerometer data processing, and VGA display control.
Features

Real-time accelerometer data acquisition via SPI
VGA display output showing a controlled white ball
Seven-segment display showing accelerometer values
LED debugging output for accelerometer data
Dynamic movement speed based on tilt angle
Adjustable stabilization for smoother control

Hardware Requirements:
Nexys A7 FPGA board
VGA monitor
FPGA programming cable

Implementation Details
The code consists of several modules:

merged_top.v: Main module connecting all components
block_controller.v: Controls ball movement based on accelerometer data
display_controller.v: Generates VGA timing signals
spi_master.v: Communicates with the accelerometer
iclk_gen.v: Generates clock for SPI communication
seg7_control.v: Controls the seven-segment display

Ball Movement
The ball movement has two distinct characteristics:

Dual-speed control: The ball moves at different speeds depending on the tilt angle of the board
Stabilization: Small movements are filtered out to prevent jitter, providing smoother control

Customization
The code can be easily modified to adjust sensitivity and behavior:

Change speed values in the block_controller.v file
Adjust stabilization thresholds for different responsiveness
Modify display elements or add game mechanics

Usage:
Program the Nexys A7 board with the provided bitstream
Connect the board to a VGA monitor
Power on the board
Tilt the board to control the ball movement
Observe accelerometer data on the seven-segment display and LEDs
