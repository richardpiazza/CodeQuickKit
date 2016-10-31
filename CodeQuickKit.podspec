#
# Be sure to run `pod lib lint CodeQuickKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = "CodeQuickKit"
  s.version = "4.1.0"
  s.summary = "An Apple Library simplifying some everyday tasks."
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

  s.osx.frameworks = 'Foundation'
  s.osx.deployment_target = "10.12"
  s.osx.source_files = 'Sources/Foundation/*', 'Sources/macOS/*'

  s.ios.frameworks = 'Foundation', 'UIKit'
  s.ios.deployment_target = "10.0"
  s.ios.source_files = 'Sources/Foundation/*', 'Sources/iOS/*'

  s.tvos.frameworks = 'Foundation', 'UIKit'
  s.tvos.deployment_target = "10.0"
  s.tvos.source_files = 'Sources/Foundation/*', 'Sources/tvOS/*'

  s.watchos.frameworks = 'Foundation'
  s.watchos.deployment_target = "3.0"
  s.watchos.source_files = 'Sources/Foundation/*', 'Sources/watchOS/*'

  s.source = { :git => "https://github.com/richardpiazza/CodeQuickKit.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.default_subspec = 'iOS'

  s.subspec 'Foundation' do |framework|
    framework.frameworks = 'Foundation'
    framework.source_files = 'Sources/Foundation/*'
  end

  s.subspec 'CoreData' do |framework|
    framework.dependency 'CodeQuickKit/Foundation'
    framework.frameworks = 'CoreData'
    framework.source_files = 'Sources/CoreData/*'
  end

  s.subspec 'macOS' do |platform|
    platform.platform = :osx, '10.12'
    platform.dependency 'CodeQuickKit/Foundation'
    #platform.source_files = 'Sources/macOS/*'
  end

  s.subspec 'iOS' do |platform|
    platform.platform = :ios, '10.0'
    platform.dependency 'CodeQuickKit/Foundation'
    platform.source_files = 'Sources/iOS/*'
  end

  s.subspec 'tvOS' do |platform|
    platform.platform = :tvos, '10.0'
    platform.dependency 'CodeQuickKit/Foundation'
    #platform.source_files = 'Sources/tvOS/*'
  end

  s.subspec 'watchOS' do |platform|
    platform.platform = :watchos, '3.0'
    platform.dependency 'CodeQuickKit/Foundation'
    #platform.source_files = 'Sources/watchOS/*'
  end

end
