Pod::Spec.new do |s|
  s.name         = "ios-NumberRangeSelector"
  s.version      = "0.1.2"
  s.summary      = "Granular selection from a numeric range for iOS."

  s.description  = <<-DESC
                   Intuitive selection from a numeric range / interval in a more intuitive way than 
                   UIPickerView or UISlider provide.
                   DESC

  s.homepage     = "https://github.com/mruegenberg/ios-NumberRangeSelector"
  s.screenshots  = "https://raw.github.com/mruegenberg/ios-NumberRangeSelector/master/doc/screenshot1.png"

  s.license      = 'MIT'

  s.author       = { "Marcel Ruegenberg" => "gh@dustlab.com" }

  s.platform     = :ios, '5.1'

  s.source       = { :git => "https://github.com/mruegenberg/ios-NumberRangeSelector.git", :tag => s.version }

  s.source_files  = '*.{h,m}'

  s.public_header_files = 'NumberRangeSelector.h'

  s.frameworks = 'UIKit', 'CoreGraphics'

  s.requires_arc = true
  
  s.dependency 'objc-utils', '>= 0.6.0'
  s.dependency 'uikit-utils', '~> 0.5.1'

end
