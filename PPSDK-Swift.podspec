Pod::Spec.new do |spec|
  spec.name         = "PPSDK-Swift"
  spec.version      = "0.2.3"
  spec.summary      = "playPORTAL SDK in Swift."
  spec.description  = <<-DESC
  Swift SDK providing access to playPORTAL services.
                   DESC

  spec.homepage     = "https://github.com/playportal-studio/PPSDK-Swift.git"
  spec.license      = "Apache"
  spec.author             = { "Lincoln Fraley" => "lincoln@dynepic.com" }
  spec.source       = { :git => "https://github.com/playportal-studio/PPSDK-Swift.git", :tag => spec.version.to_s }
  spec.source_files  = "Source/*.swift"
  spec.swift_version = '4.2'
  spec.ios.deployment_target = '10.0'
  spec.dependency 'Alamofire', '~> 4.7'
  spec.dependency 'KeychainSwift', '~> 12.0'
  spec.resource_bundles = {
      'PPSDK-Swift-Assets' => ['Resources/*']
  }
end
