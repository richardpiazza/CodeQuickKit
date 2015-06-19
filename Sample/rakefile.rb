#!/usr/bin/ruby

class XcodeBuildWrapper
	def self.getSDKWithName(name)
		if (name == nil || name.length == 0)
			raise "#{__method__} Failed; sdk name is nil or empty."
		end
		
		sdk = nil
		IO.popen("xcodebuild -showsdks").each do |line|
			if (line.include? name)
				length = line.length - 2
				start = line.index("-sdk ") + 5
				sdk = line[start..length]
				return sdk
			end
		end
		return sdk
	end

	def self.getiPhoneOSSDK()
		return getSDKWithName("iphoneos")
	end

	def self.getiPhoneSimulatorSDK()
		return getSDKWithName("iphonesimulator")
	end
	
	def self.packageFrameworkSchemes(frameworkSchemes)
		if (frameworkSchemes == nil)
			raise "#{__method__} Failed; frameworkSchemes is nil."
		end
		
		if (!system("rm -r pkg/*"))
			#ignore
		end
		
		frameworkSchemes.each do |scheme|
			framework_name = scheme + ".framework"
			simulator_framework = "build/Release-iphonesimulator/#{framework_name}"
			simulator_headers = "#{simulator_framework}/Headers"
			iphone_framework = "build/Release-iphoneos/#{framework_name}"
			iphone_headers = "#{iphone_framework}/Headers"
			universal_framework = "pkg/#{framework_name}"
			universal_headers = "#{universal_framework}/Headers"
			
			iOSSDK = getiPhoneOSSDK()
			simulatorSDK = getiPhoneSimulatorSDK()
			
			if (!system("mkdir -p #{universal_headers}"))
				raise "#{__method__} failed for scheme #{scheme} - Unable to create headers directory"
			end
			
			if (!system("xcodebuild ARCHS='armv7 armv7s arm64' -target '#{scheme}' -destination=build -configuration Release -sdk #{iOSSDK} clean build RUN_CLANG_STATIC_ANALYZER=NO"))
				raise "#{__method__} failed for scheme #{scheme} - iOS Build Failed"
			end
			
			if (!system("xcodebuild ARCHS='i386 x86_64' -target '#{scheme}' -destination=build -configuration Release -sdk #{simulatorSDK} clean build RUN_CLANG_STATIC_ANALYZER=NO"))
				raise "#{__method__} failed for scheme #{scheme} - Simulator Build Failed"
			end
			
			if (!system("lipo -create '#{iphone_framework}/#{scheme}' '#{simulator_framework}/#{scheme}' -output '#{universal_framework}/#{scheme}'"))
				raise "#{__method__} failed for scheme #{scheme} - Unable to build fat binary"
			end
			
			if (!system("cp #{iphone_framework}/*.plist #{universal_framework}/"))
				raise "#{__method__} failed for scheme #{scheme} - Failed to copy Plist"
			end
			
			if (!system("cp #{iphone_framework}/*.png #{universal_framework}/"))
				#ignore
			end
			if (!system("cp #{iphone_framework}/*.ttf #{universal_framework}/"))
				#ignore
			end
			if (!system("cp -r #{iphone_framework}/*.bundle #{universal_framework}/"))
				#ignore
			end
			
			if (File.directory?("#{iphone_headers}/"))
				if (!system("cp -r #{iphone_headers}/ #{universal_headers}/"))
					raise "#{__method__} failed for scheme #{scheme} - Unable to copy headers"
				end
			end
			
			if (!system("zip -r 'pkg/frameworks.zip' #{universal_framework}"))
				raise "#{__method__} failed for scheme #{scheme} - Unable to compress framework"
			end
		end
	end
end

task :default do
	system "rake -f #{__FILE__} --tasks"
end

namespace :xcode do
	desc "Uses 'xcodebuild' and 'lipo' to create signed, universal Cocoa Touch frameworks"
	task :packageFramework do
		schemes = ["CodeQuickKit"]
		XcodeBuildWrapper.packageFrameworkSchemes(schemes)
	end
end
