# some-sketchy-arm
An ARM assembly language program to take an image and "sketch" it on an LCD in the same way that a human might sketch the image.

## Overview
This program takes a 2D array of pixel values stored in memory that represent an image. The program performs edge detection on the image, and prints a blank canvas to the LCD before printing the pixels of the edges in a human like fashion.

Here is a GIF of a snippet of the Sketching.

![sketch-lapse-1](Images/sketch-lapse-1.gif)


![SketchLapseSmall](Images/SketchLapseSmall.gif)

## Motivation 
In our first year in college we were given an ARM assembly image manipulation assignment. The first two parts of the assignment were to change the Brightness and Contrast of an image and to add a Motion-Blur effect to an image. For the third part of the assignment we were tasked to implement our own effect on the image.  

  It struck me that all the effects that the class were implementing were static, and I decided I would like to implement a more dynamic manipulation of the image. All around the lab, every image was being printed from left to right row by row on the LCDs. I thought it would be more interesting to print pixels on the LCD in a different order.  
  
  There are algorithms already established on the internet for most effects that might pop into people's mind for part three of the assignment, and while I was interested in trying to implement edge-detection, I also wanted to come up with an algorithm of my own to manipulate the image. So I came up with this algorithm to manipulate the order in which the pixels from the edges inside the image are printed on the LCD.

## Technical details
Each pixel is a 32bit RGB value stored contigously in memory.

## The Algorithm
Another section in memory is allocated so that the program can make a copy of the image. 
