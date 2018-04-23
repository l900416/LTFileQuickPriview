
Pod::Spec.new do |s|

  s.name         = "LTFileQuickPreview"
  s.version      = "0.0.4"
  s.summary      = "Support both online and local document & Multi-Media File Preview."
  s.license      = "MIT"
  s.author             = { "liangtong" => "l900416@163.com" }

  s.homepage     = "https://github.com/l900416/LTFileQuickPriview"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.frameworks = "Foundation", "UIKit"

  s.source       = { :git => "https://github.com/l900416/LTFileQuickPriview.git", :tag => "#{s.version}" }
  s.source_files  =  "LTQuickPreview/*.{h,m}"
  s.public_header_files = "LTQuickPreview/*.h"

end
