Pod::Spec.new do |spec|
  spec.name         = "GaugeSlider"
  spec.version      = "1.0.1"
  spec.summary      = "Highly customizable GaugeSlider primarily designed for a Smart Home app."

  spec.homepage     = "https://github.com/edgar-zigis/GaugeSlider"
  spec.screenshots  = "https://raw.githubusercontent.com/edgar-zigis/GaugeSlider/master/sampleGif.gif"


  spec.license      = { :type => 'MIT', :file => './LICENSE' }

  spec.author       = "Edgar Žigis"

  spec.platform     = :ios
  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5.0'
  
  spec.source       = { :git => "https://github.com/edgar-zigis/GaugeSlider.git", :tag => "#{spec.version}" }

  spec.source_files  = "GaugeSlider/**/*.{swift}"
end
