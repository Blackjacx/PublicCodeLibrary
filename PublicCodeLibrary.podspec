Pod::Spec.new do |s|
  s.name         = "PublicCodeLibrary"
  s.version      = "1.0.0"
  s.summary      = "Static Library Project containing code to simplify daily development tasks."
  s.homepage     = "http://github.com/Blackjacx/PublicCodeLibrary"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Stefan Herold" => "stefan.herold@gmail.com" }
  s.source       = { :git => "https://github.com/Blackjacx/PublicCodeLibrary.git", :tag => "1.0.0" }
  s.platform     = :ios, '6.1'
  s.ios.deployment_target = '5.0'
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.requires_arc = true
end
