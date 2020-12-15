# Installation
***
To use this library, you will first need to install the Cocoapods dependency manager. Check [here](https://guides.cocoapods.org/using/getting-started.html) for a how-to on installation. 

Next, follow [this](https://guides.cocoapods.org/using/using-cocoapods.html) guide to setup your Xcode project to use Cocoapods.

Then, in your **Podfile**, add this line `pod 'DXSDK-Swift', :git => 'https://github.com/DynepicX-DX/DXSDK-Swift'`. Your **Podfile** should look something like this:

	target 'YourProjectName' do
    	use_frameworks!

  		pod 'DXSDK-Swift', :git => 'https://github.com/DynepicX-DX/DXSDK-Swift'

	end
	
Finally, from the command line inside your project's directory, run `pod install`. 
