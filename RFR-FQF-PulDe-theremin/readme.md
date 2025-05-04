# RFR-FQF-PulDe (Pulse Decay)

# Overview

This folder contains all the files for the Requiem for Radio: Pulse Decay performance.
The performer plays the theremin on stage. Behind her, blueprintlike
images of the Sackville radio towers are projected. The sounds of the
corresponding radio tower is played back on speakers.
The theremin can play actual theremin sounds, but it is also used to
select and crossfade between the 13 radio towers.

# Running the Code

## Arduino
Just plug in the box via USB and you're good!

## SuperCollider
Assuming you've installed the dependencies, recompile the code (CMD + Shift + L). Then run the server (CMD-B) - the text at the bottom right should be green now. Then, select the closed parenthesis ")" on line 31 of the code, and run it using (CMD + Enter). Stop by using (CMD + .)

## Processing
After installation the OSC dependency, you can just hit the Play button to run the code; the Escape key stops it.

If the menu bar appears on the projector, move the mouse pointer on the
screen and click. Clicking on another window makes the menu bar appear.
Don’t panic. Move the mouse pointer on the screen and click.

# Folders and Files

## ADC_theremin_20161029

This folder contains the Arduino sketch that is used to convert the theremin’s
CV outputs to digital signals. 

The CV outputs (pitch and volume) are
connected to the analog pins 0 and 1 of the Arduino. 
Also, 10kW resistors are
connected from the analog pins to the ground. They act as voltage dividers.
There are also two diodes that prevent negative voltages from reaching the
Arduino’s analog pins.

The data is sent from the Arduino to the computer using the SLIP protocol.
Each packet contains 4 bytes: two bytes for the pitch and two bytes
for the volume. The Arduino’s ADCs are 10 bits, so only two bits of the
MSB are used.

On the box, the connector on the right is for pitch (CV) and the left one
is for volume (CV).

## bluePrints

This folder contains a Processing program that displays the towers’ bluePrints.
The images are in the data subfolder. This program loads all the image files. It expects the files to be called
RfrPd_C_.jpg, RfrPd_D_.jpg, and so on.

This program receives OSC messages from SuperCollider on port 60120.

/alphaChannels is Thirteen floats between 0.0 and 1.0
/volume is One float between 0.0 and 1.0

The alpha channel of each of the 13 images is respectively affected by the
13 alphaChannel values. The volume affects the alpha channel of all images
at once, essentially allowing the fade to black at any point.

The pitch antenna of the theremin controls which image (or tower) is
visible.

Depending on the computer used, you may need to lower the framerate.
Ideally, it should run at 30 fps, but it can run at 15.

We had issues with images not being centered. It is
because of line 44 in void draw.


## sc-code

This folder contains all the SuperCollider code. The main file is test.scd.
It should probably be renamed to theremuino.scd.

The media subfolder contains all the sound files required for the performance.

There are two soundfiles for each tower: drone and glitch. Both files
are played back together all the time.

The prep subfolder contains more SuperCollider code.


# Installation

## Git
The code depends on a few Quarks (which are extensions for SuperCollider).
Installing Quarks requires Git.
Git comes installed with the program Fork.

You can download Git on git-scm.com. If git is installed
with this link, you may need to run a command in the terminal to make it
work. (At least, this is the case on Mac OS X 10.12.) Follow instructions in
the git download’s readme file.
Also, at least on MacOS X 10.12, you need to disable rootless system integrity
protection as explained here: http://ntfs-formac.com/how-to-disable-sip-rootless-system-

## SuperCollider
In SuperCollider, to install Quarks, you need to type this line of code in the text editor:
Quarks.gui;
Execute it by pressing Cmd+Enter.

You need all these Quarks:
- dewdroplib (this one installs a bunch of other ddw Quarks)
- wslib
- XML

After this, go to the main editor and recompile the code (CMD + Shift + L on Mac)

## Processing
Go to "Tools" in the main menu and select "Manage Tools". Go to the "Libraries" tab and search for "oscP5" (An Open Sound Control implementation by Andreas Schlegel) and install it. That's it!