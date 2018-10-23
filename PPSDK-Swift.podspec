Pod::Spec.new do |spec|
  spec.name         = "PPSDK-Swift"
  spec.version      = "0.0.2"
  spec.summary      = "playPORTAL SDK in Swift."
  spec.description  = <<-DESC
  playPORTAL SDK in Swift 
                   DESC

  spec.homepage     = "https://github.com/playportal-studio/PPSDK-Swift"
  spec.license      = "Apache"
  spec.author             = { "Lincoln Fraley" => "lincoln@dynepic.com" }
  spec.source       = { :git => "https://github.com/playportal-studio/PPSDK-Swift", :branch => "pod" }
  spec.source_files  = "Source/*.swift"
end
