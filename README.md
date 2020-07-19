# GaugeSlider

Highly customizable GaugeSlider primarily designed for a Smart Home app.
##### Minimum iOS version 11.0

![alt text](https://github.com/edgar-zigis/GaugeSlider/blob/master/sample.gif?raw=true)

### Carthage

```
github "edgar-zigis/GaugeSlider" ~> 1.0.1
```
### Cocoapods

```
pod 'GaugeSlider', '~> 1.0.1'
```
### Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/edgar-zigis/GaugeSlider.git", .upToNextMajor(from: "1.1.0"))
]
```
### Usage
``` swift
let v = GaugeSliderView()
v.blankPathColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1) //  -> inactive track color
v.fillPathColor = UIColor(red: 74/255, green: 196/255, blue: 192/255, alpha: 1) //  -> filled track color
v.indicatorColor = UIColor(red: 94/255, green: 187/255, blue: 169/255, alpha: 1)
v.unitColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
v.placeholderColor = UIColor(red: 139/255, green: 154/255, blue: 158/255, alpha: 1)
v.unitIndicatorColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.2)
v.customControlColor = UIColor(red: 47/255, green: 190/255, blue: 169/255, alpha: 1)
v.unitFont = UIFont.systemFont(ofSize: 67)
v.placeholderFont = UIFont.systemFont(ofSize: 17, weight: .medium)
v.unitIndicatorFont = UIFont.systemFont(ofSize: 16, weight: .medium)
v.customControlButtonTitle = "• Auto"
v.isCustomControlActive = false
v.customControlButtonVisible = true
v.placeholder = "Warming"
v.unit = "°"  //  -> change default unit from temperature to anything you like
v.progress = 80 //  -> 0..100 a way to say percentage
v.value = 10
v.minValue = 5
v.maxValue = 25
v.countingMethod = GaugeSliderCountingMethod.easeInOut // -> sliding animation style
v.delegationMode = .singular
v.leftIcon = UIImage(named: "snowIcon")
v.rightIcon = UIImage(named: "sunIcon")
```
### Remarks
It can be used both programmatically and with story boards. Samples are available at GaugeSliderTest
