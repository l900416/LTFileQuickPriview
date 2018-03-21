
Pod::Spec.new do |s|

  s.name         = "LTFileQuickPreview"
  s.version      = "0.0.4"
  s.summary      = "Support both online and local document & Multi-Media File Preview."

  s.description  = <<-DESC
                    Online and local document & Multi-Media File Preview. Very easy to use.
                   DESC

  s.homepage     = "https://github.com/l900416/LTFileQuickPriview"

   s.license      = "MIT"

   s.author             = { "liangtong" => "l900416@163.com" }

   s.platform     = :ios, "9.0"

   s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/l900416/LTFileQuickPriview.git", :tag => "#{s.version}" }
  s.source_files  = "LTQuickPreview", "LTQuickPreview/*.{h,m}"
  s.public_header_files = "LTQuickPreview/**/*.h"
  s.resources = "Resource/*.png"
  s.frameworks = "Foundation", "UIKit"
  s.requires_arc = true

end
