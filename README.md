# cordova-plugin-video-trimming-editor
動画ファイルを時系列でトリミングするためのUI、機能を実現するためのcordovaプラグイン。  
このプラグインは以下のネイティブライブラリを使用またはインスパイアしたものです。  

https://github.com/iknow4/Android-Video-Trimmer  
https://github.com/HHK1/PryntTrimmerView  

また、Android-Video-Trimmerで使用されているffmpegの部分のコードについてはライセンスに対する懸念から削除して使用せずに実現しました。  

## Requirement
cordova >= 7.1.0  
cordova-ios >= 4.5.0  
cordova-android >= 8.0.0  

## Installation
```
cordova plugin add cordova-plugin-video-trimming-editor
```

## Supported Platforms
- iOS  
- Android  

## Example

使用例  
```js

var params = {
};

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
今後追加したい機能としては以下の予定です。
・画面テーマまたは各要素のカラーを利用者側で設定できるようにする。  
・各要素のボタンテキストを固定値としているので利用者側で設定できるようにする。  
・トリミング後のファイルに対して圧縮する機能を追加する。  

