#  Roku Universal Analytics

## Overview
This is free Univeral Analytics tracking library for Roku player.
It allow you to track your Channel activity within Universal Analytics.

## What can this library do for you
* Event Tracking
* Pageviews Tracking
* Roku Model and Version ( as Custom Dimensions )
* Real Screen Resolution and Aspect Ratio
* Unique Roku Players based on a random UUIDv4
* AppName and AppVersion ( Your channel name and version ) 

## How to use it
Just initialize the library with this line just before your channel setup
UA_Init("UA-XXXXXXXXX-Y")

After you have initilized it you can start sending events and pageviews:
* UA_trackEvent("Category","Action","Label","Value")
All parameters are mandatory if you don't need to send a label or value, just set them as ""
* UA_trackPageview("/el_padrino_iii_trailer")

## Configuration
If you wanna track the roku model and version used by your clients, please set 2 dimensions ( dimension1 and dimension2 )
with a visit Scope within your Google Analytics Admin Section

## Example
Check the demo folder for a modified "Custom Video Player Channel" example for the SDK, that sends this info to Google Analytics
* An Event when the channel is loaded
* An Event when the channel is closed
* An event every time the pause/resume button is pressed
* An event ( with a value ) when the user forwards or rewards the video
* A pageview when the video is loaded
