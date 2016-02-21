#
# Be sure to run `pod lib lint CodeQuickKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CodeQuickKit"
  s.version          = "1.1.0"
  s.summary          = "An iOS Library simplifying some everyday tasks."
  s.description      = <<-DESC
  CodeQuickKit is a collection of Objective-C Categories and helper classes designed to 
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

  s.source_files = 'CodeQuickKit-ObjC/*'
  # s.resource_bundles = { 'CodeQuickKit' => ['Pod/Assets/*.png'] }

  s.public_header_files = 'CodeQuickKit-ObjC/*.h'
  s.frameworks = 'UIKit', 'CoreData'
end
