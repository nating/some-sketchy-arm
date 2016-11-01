# some-sketchy-arm
A program to take an image and "sketch" it on an LCD in the same way that a human might sketch the image.

## Overview
This program takes a 2D array of pixel values stored in memory that represent an image. The program performs edge detection on the image, and the edges are drawn on a blank canvas of an LCD.

(GIF of sketching to be inserted here)

## Technical details
Each pixel is a 32bit RGB value stored contigously in memory.

## The Algorithm
Another section in memory is allocated so that the program can make a copy of the image. 
