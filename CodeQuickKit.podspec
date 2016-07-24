#
# Be sure to run `pod lib lint CodeQuickKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = "CodeQuickKit"
  s.version = "2.7.0"
  s.summary = "An iOS Library simplifying some everyday tasks."
  s.description = <<-DESC
  CodeQuickKit is a collection of Swift extensions and classes designed to 
  quicken iOS development. This collection includes (but not limited to): logging, 
  NSObject/JSON de/serialization, JSON Web APIs, UIStoryboard/UIAlertController shortcuts, 
  and CoreData wrappers.
                     DESC
  s.homepage = "https://github.com/richardpiazza/CodeQuickKit"
  s.license = 'MIT'
  s.author = { "Richard Piazza" => "github@richardpiazza.com" }
  s.social_media_url = 'https://twitter.com/richardpiazza'

  s.source = { :git => "https://github.com/richardpiazza/CodeQuickKit.git", :tag => s.version.to_s }
  s.platforms = { :ios => '9.1', :tvos => '9.0' }
  s.requires_arc = true
  s.default_subspec = 'iOS'

  s.subspec 'Foundation' do |framework|
    #framework.platform = :ios, '9.1'
    framework.frameworks = 'Foundation'
    framework.source_files = 'Sources/Foundation/*'
  end

  s.subspec 'CoreData' do |framework|
    framework.dependency 'CodeQuickKit/Foundation'
    framework.frameworks = 'CoreData'
    framework.source_files = 'Sources/CoreData/*'
  end

  s.subspec 'UIKit' do |framework|
    framework.dependency 'CodeQuickKit/Foundation'
    framework.frameworks = 'UIKit'
    framework.source_files = 'Sources/UIKit/*'
  end

  s.subspec 'iOS' do |platform|
    platform.dependency 'CodeQuickKit/UIKit'
    platform.platform = :ios, '9.1'
    platform.source_files = 'Sources/iOS/*'
  end

  s.subspec 'tvOS' do |platform|
    platform.platform = :tvos, '9.0'
    platform.dependency 'CodeQuickKit/Foundation'
    #platform.source_files = 'Sources/tvOS/*'
  end

end
