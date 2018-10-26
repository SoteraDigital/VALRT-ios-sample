p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica; min-height: 14.0px} p.p2 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px Helvetica} p.p3 {margin: 0.0px 0.0px 0.0px 0.0px; font: 14.0px Calibri} p.p4 {margin: 0.0px 0.0px 0.0px 0.0px; font: 14.0px Calibri; min-height: 17.0px} p.p5 {margin: 0.0px 0.0px 0.0px 0.0px; font: 11.0px Menlo; color: #643820} span.s1 {font-variant-ligatures: no-common-ligatures} span.s2 {font-variant-ligatures: no-common-ligatures; color: #c41a16} 

VSN Connect - README

Version 1.0

Last Updated: 8/19/2014

This sample code will help you get started with the VSN 

sdk.  It provides sample code for how to:

-scan for devices

-connected to a pre-defined device address

-Send the correct verification code to the puck

-And then enable short button presses and display the status/press on the screen

IMPORTANT:

1) To get started you’ll need to change the #define VALRT_DEVICE_LOCAL_NAME to be the local name of your device.  This is defined in ViewController.m.

For example:

#define VALRT_DEVICE_LOCAL_NAME @"V.ALRT A3:37:53"

2) If you need help finding the local name of your V.ALRT, we recommend using a tool called Light Blue.  You can download it here:

https://itunes.apple.com/us/app/lightblue/id639944780?mt=12

3) Note, the iOS simulator 

bluetooth support is limited to the device only, so running this code in the simulator will not let you use 

bluetooth.
