Pod::Spec.new do |s|
  s.name = "CodeQuickKit"
  s.version = "6.6.0"
  s.summary = "An Apple Library simplifying some everyday tasks."
  s.description = <<-DESC
  CodeQuickKit is a collection of Swift extensions and classes designed to aid in
  app development. This collection includes (but not limited to): logging, file management,
  JSON Web APIs, UIStoryboard/UIAlertController shortcuts, date handling, and environment data.
                     DESC
  s.homepage = "https://github.com/richardpiazza/CodeQuickKit"
  s.license = 'MIT'
  s.author = { "Richard Piazza" => "github@richardpiazza.com" }
  s.social_media_url = 'https://twitter.com/richardpiazza'

  s.source = { :git => "https://github.com/richardpiazza/CodeQuickKit.git", :tag => s.version.to_s }
  s.source_files = 'Sources/*'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.osx.deployment_target = "10.13"
  s.osx.frameworks = 'Foundation'
  s.ios.deployment_target = "11.0"
  s.ios.frameworks = 'Foundation', 'UIKit'
  s.tvos.deployment_target = "11.0"
  s.tvos.frameworks = 'Foundation', 'UIKit'
  #s.watchos.deployment_target = "4.0"
  #s.watchos.frameworks = 'Foundation'

end
