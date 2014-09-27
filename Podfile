source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
xcodeproj 'Xcode/Awful', 'Awful Beta' => :release, 'Awful App Store' => :release
link_with 'Awful'
inhibit_all_warnings!

pod 'AFNetworking', '2.4.1'
pod 'ARChromeActivity', '1.0.2'
pod 'GRMustache', '7.3.0'
pod 'HTMLReader', '0.5.6'
pod 'ImgurAnonymousAPIClient', '0.2'
pod 'JLRoutes', '1.5.1'
pod 'MRProgress/Overlay', '0.7.0'
pod 'PSMenuItem', '0.0.1'
pod 'SVPullToRefresh', :head
pod 'TUSafariActivity', '1.0.0'
pod 'WebViewJavascriptBridge', '4.1.4'

target :ScrapingTests, :exclusive => true do
  pod 'HTMLReader', '0.5.6'
end

target :SmileyFramework, :exclusive => true do
  pod 'HTMLReader', '0.5.6'
end

# Custom text atop the "Acknowledgements" Settings screen.
class ::Pod::Generator::Acknowledgements
  def header_text
    "Awful uses these third-party libraries:"
  end
end

post_install do |installer|
  plist = Xcodeproj.read_plist(installer.sandbox_root + 'Target Support Files/Pods/Pods-acknowledgements.plist')
  licenses = plist['PreferenceSpecifiers']
  
  # Delete "generated by CocoaPods"
  licenses.delete_at(-1)
  
  # Standalone license files.
  Dir['Vendor/**/LICENSE.txt'].each do |path_to_license|
    licenses << {
      :FooterText => File.open(path_to_license).read,
      :Title => path_to_license.split(File::SEPARATOR)[1],
      :Type => "PSGroupSpecifier"
    }
  end
  
  # Licenses from header files.
  Dir['Vendor/*.h'].each do |path_to_header|
    lines = []
    File.open(path_to_header) do |header|
      header.each do |line|
        break if line[0, 2] != "//"
        lines << line[2..-1].strip
      end
    end
    licenses << {
      :FooterText => lines.join("\n"),
      :Title => File.basename(path_to_header, '.h'),
      :Type => "PSGroupSpecifier"
    }
  end
  Xcodeproj.write_plist(plist, 'Resources/Settings.bundle/Acknowledgements.plist')
end
