#
# Be sure to run `pod lib lint CodeQuickKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CodeQuickKit"
  s.version          = "2.0.1"
  s.summary          = "An iOS Library simplifying some everyday tasks."
  s.description      = <<-DESC
  CodeQuickKit is a collection of Swift extensions and classes designed to 
  quicken iOS development. This collection includes (but not limited to): logging, 
  NSObject/JSON de/serialization, JSON Web APIs, UIStoryboard/UIAlertController shortcuts, 
  and CoreData wrappers.
                       DESC

  s.homepage         = "https://github.com/richardpiazza/CodeQuickKit"
  s.license          = 'MIT'
  s.author           = { "Richard Piazza" => "github@richardpiazza.com" }
  s.source           = { :git => "https://github.com/richardpiazza/CodeQuickKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/richardpiazza'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'CodeQuickKit-Swift/*'
#  s.public_header_files = 'CodeQuickKit-Swift/*.h'
  s.frameworks = 'UIKit', 'CoreData'
end
