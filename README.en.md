# cordova-plugin-video-trimming-editor
Cordova plug-in for realizing UI and functions for trimming video files in time series.  
This plug-in uses or is inspired by the following native libraries.  

https://github.com/iknow4/Android-Video-Trimmer  
https://github.com/HHK1/PryntTrimmerView  

In addition, the code of the ffmpeg part used in Android-Video-Trimmer has been deleted without being used due to concerns about licensing.  

* Screen image of iOS and Android  
![ios](https://user-images.githubusercontent.com/4780752/63224897-d8d56700-c205-11e9-8756-0d17b3ca4b3e.png)
![android](https://user-images.githubusercontent.com/4780752/63224898-d96dfd80-c205-11e9-808c-2d6e0e2decbc.png)

## Requirement
cordova >= 7.1.0  
cordova-ios >= 4.5.0  
cordova-android >= 8.0.0  

https://github.com/dpa99c/cordova-plugin-androidx  
https://github.com/nrikiji/cordova-plugin-carthage-support  
https://github.com/akofman/cordova-plugin-add-swift-support  
[Carthage(>= 0.3.3)](https://github.com/Carthage/Carthage)  


## Installation
```
cordova plugin add cordova-plugin-video-trimming-editor
```

## Supported Platforms
- iOS  
- Android  

## Example

Example
```js

VideoTrimmingEditor.open(
  {
    input_path: '/path/to/xxx.mp4',
    video_max_time: 10,
  },
  function(result) {
    console.log(result); // { output_path: "/path/to/zzz.mp4" }
  },
  function(error) {
  }
);
```

## Features
The following functions are planned to be added in the future.  
・ Enable the user to set the screen theme or the color of each element  
・ Because the button text of each element is a fixed value, the user can set it Add a function to compress the trimmed file  
・ Layout adjustment on iPhoneX  


