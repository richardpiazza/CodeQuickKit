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
	
	def self.getOSXSDK()
		return getSDKWithName("macosx")
	end
	
	def self.packageSchemeTarget(scheme, target, platform)
		if (scheme == nil)
			raise "#{__method__} Failed; scheme is nil."
		end
		if (target == nil)
			raise "#{__method__} Failed; target is nil."
		end
		if (platform == nil)
			raise "#{__method__} Failed; platform is nil."
		end
		
		Dir.chdir(platform) do
			if (!system("rm -r pkg/*"))
				#ignore
			end
			
			if (platform == "iOS")
				framework_name = target + ".framework"
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
				
				if (!system("xcodebuild ARCHS='armv7 armv7s arm64' -target '#{target}' -destination=build -configuration Release -sdk #{iOSSDK} clean build RUN_CLANG_STATIC_ANALYZER=NO"))
					raise "#{__method__} failed for scheme #{scheme} - iOS Build Failed"
				end
				
				if (!system("xcodebuild ARCHS='i386 x86_64' -target '#{target}' -destination=build -configuration Release -sdk #{simulatorSDK} clean build RUN_CLANG_STATIC_ANALYZER=NO"))
					raise "#{__method__} failed for scheme #{scheme} - Simulator Build Failed"
				end
				
				if (!system("lipo -create '#{iphone_framework}/#{target}' '#{simulator_framework}/#{target}' -output '#{universal_framework}/#{target}'"))
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
				if (!system("cp -r #{iphone_framework}/*.sh #{universal_framework}/"))
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
			elsif (platform == "OSX")
				framework_name = target + ".framework"
				architecture_framework = "build/Release/#{framework_name}"
				architecture_headers = "#{architecture_framework}/Headers"
				universal_framework = "pkg/#{framework_name}"
				universal_headers = "#{universal_framework}/Headers"
				
				osxSDK = getOSXSDK()
				
				if (!system("mkdir -p #{universal_headers}"))
					raise "#{__method__} failed for scheme #{scheme} - Unable to create headers directory"
				end
				
				if (!system("xcodebuild -target '#{target}' -destination=build -configuration Release -sdk #{osxSDK} clean build RUN_CLANG_STATIC_ANALYZER=NO"))
					raise "#{__method__} failed for scheme #{scheme} - Simulator Build Failed"
				end
				
				if (!system("lipo -create '#{architecture_framework}/#{target}' -output '#{universal_framework}/#{target}'"))
					raise "#{__method__} failed for scheme #{scheme} - Unable to build fat binary"
				end
				
				if (!system("cp #{architecture_framework}/Resources/*.plist #{universal_framework}/"))
					raise "#{__method__} failed for scheme #{scheme} - Failed to copy Plist"
				end
				
				if (!system("cp #{architecture_framework}/Resources/*.png #{universal_framework}/"))
					#ignore
				end
				if (!system("cp #{architecture_framework}/Resources/*.ttf #{universal_framework}/"))
					#ignore
				end
				if (!system("cp -r #{architecture_framework}/Resources/*.bundle #{universal_framework}/"))
					#ignore
				end
				if (!system("cp -r #{architecture_framework}/Resources/*.sh #{universal_framework}/"))
					#ignore
				end
				
				if (File.directory?("#{architecture_headers}/"))
					if (!system("cp -r #{architecture_headers}/ #{universal_headers}/"))
						raise "#{__method__} failed for scheme #{scheme} - Unable to copy headers"
					end
				end
				
				if (!system("zip -r 'pkg/frameworks.zip' #{universal_framework}"))
					raise "#{__method__} failed for scheme #{scheme} - Unable to compress framework"
				end
			else
				raise "#{__method__} failed for scheme #{scheme} - Unknown platform #{platform}"
			end
		end
	end
end

task :default do
	system "rake -f #{__FILE__} --tasks"
end

namespace :xcode do
	desc "Uses 'xcodebuild' and 'lipo' to create signed, universal Cocoa frameworks"
	task :packageFramework do
		XcodeBuildWrapper.packageSchemeTarget("CodeQuickKitiOS", "CodeQuickKit", "iOS")
		XcodeBuildWrapper.packageSchemeTarget("CodeQuickKitOSX", "CodeQuickKit", "OSX")
	end
end
