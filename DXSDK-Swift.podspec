Pod::Spec.new do |spec|
  spec.name         = "DXSDK-Swift"
  spec.version      = "1.0.0"
  spec.summary      = "DX SDK for Swift."
  spec.description  = <<-DESC
  Swift SDK providing access to DX services.
                   DESC

  spec.homepage     = "https://gitlab.motar.io/sdks/swift-temp"
  spec.license      = "Apache"
  spec.author             = { "Lincoln Fraley" => "lincoln@dynepic.com" }
  spec.source       = { :git => spec.homepage }
  spec.source_files  = "Source/*.swift"
  spec.swift_version = '4.2'
  spec.ios.deployment_target = '10.0'
  spec.dependency 'KeychainSwift', '~> 12.0'
  spec.resource_bundles = {
      'DXSDK-Swift-Assets' => ['Resources/*']
  }
end
