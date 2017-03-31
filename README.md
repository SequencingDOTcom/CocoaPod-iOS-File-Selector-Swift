# File Selector CocoPod plugin for adding Sequencing.com's Real-Time Personalization technology to iOS apps coded in Swift
This repo contains the plug-n-play CocoaPods plugin for implementing a customizable File Selector so your app can access files stored securely at [Sequencing.com](https://sequencing.com/). 

This CocoaPods plugin can be used to quickly add a File Selector to your app. By adding this File Selector to your app, you're app user will be able to select a file stored securely in the user's Sequencing.com account. Your app will then be able to use the genetic data in this file to provide the user with Real-Time Personalization.

While the File Selector works out-of-the-box, it is also fully customizable.

A 'Master CocoaPods Plugin' is also available. The Master Plugin contains a customizable, end-to-end solution that quickly adds all necessary code to your app for Sequencing.com's Real-Time Personalization. 

Once the Master Plugin is added to your app all you'll need to do is:

1. add your [OAuth2 secret](https://sequencing.com/developer-center/new-app-oauth-secret)
2. add one or more [App Chain numbers](https://sequencing.com/app-chains/)
3. configure your app based on each [app chain's possible responses](https://sequencing.com/app-chains/)

To code Real-Time Personalization technology into apps, developers may [register for a free account](https://sequencing.com/user/register/) at Sequencing.com. App development with RTP is always free.

Contents
=========================================
* Related repos
* CocoaPods plugin integration
* Resources
* Maintainers
* Contribute

Related repos
=========================================
**Master Plugin is available in the following languages:**
* [Swift (CocoaPod plugin)](https://github.com/SequencingDOTcom/CocoaPods-iOS-Master-Plugin-Swift)
* [Objective-C (CocoaPod plugin)](https://github.com/SequencingDOTcom/CocoaPods-iOS-Master-Plugin-ObjectiveC)
* [Android (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-Master-Plugin-Java)
* [Java (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-Master-Plugin-Java) 

**File Selector is available in the following languages:**
File Selector Plugins
* Swift (CocoaPod plugin) <-- this repo
* [Objective-C (CocoaPod plugin)](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC)
* [Android (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-File-Selector-Java)
* [Java (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-File-Selector-Java) 

File Selector Code
* [Swift (code)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/swift)
* [Objective-C (code)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/objective-c)
* [Android (code)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/android)
* [PHP](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/php)
* [Perl](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/perl)
* [Python (Django)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/python-django)
* [Java (Servlet)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/java-servlet)
* [Java (Spring)](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/java-spring)
* [.NET/C#](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/tree/master/dot-net-cs)

CocoaPods plugin integration
======================================
Please follow this guide to install File Selector module in your existed or new project.


### Step 1: Install OAuth module and File Selector modules

* see [CocoaPods guides](https://guides.cocoapods.org/using/using-cocoapods.html)

* reference to OAuth CocoaPods plugin: [OAuth plugin Swift (CocoaPods plugin)](https://github.com/SequencingDOTcom/CocoaPod-iOS-OAuth-Swift)

* File selector module prepared as separate module, but it depends on a Token object from OAuth plugin. File selector can execute request to server for files with token object only. Thus you need 2 modules to be installed and set up: ```OAuth``` and ```File Selector``` modules

* create a new project in Xcode
	
* create Podfile in your project directory: 
	```
	$ pod init
	```
		
* specify following parameters in Podfile: 
	```
	pod 'sequencing-file-selector-api-swift', '~> 2.0.2'
	```		
		
* install the dependency in your project: 
	```
	$ pod install
	```
		
* always open the Xcode workspace instead of the project file: 
	```
	$ open *.xcworkspace
	```



### Step 2: Set up OAuth plugin

* reference to OAuth CocoaPods plugin: [OAuth plugin Swift (CocoaPods plugin)](https://github.com/SequencingDOTcom/CocoaPod-iOS-OAuth-Swift)



### Step 3: Register File Selector framework for Swift project
	
* first of all you need to create bridging header file. Select File > New > File > Header File > name it as
	```
	project-name-Bridging-Header.h
	```

* add SQOAuthFramework class import in the bridging header file

	```
	#import <FileSelector/SQFileSelectorFramework.h>
	```

* register your bridging header file in the project settings
	select your project > project target > Build Settings > Objective-C Bridging Header
	specify path for bridging header file
	```
	$(PROJECT_DIR)/project-name-Bridging-Header.h
	```
	

	
### Step 4: Use File Selector

* subscribe your class to file selector protocol
	```
	SQFileSelectorProtocol
	```
			
* implement methods from ```SQFileSelectorProtocol``` protocol
	```
	func selectedGeneticFile(_ file: NSDictionary) -> Void {
    }
    
    func errorWhileReceivingGeneticFiles(_ error: Error!) {
    }
    
    
    func closeButtonPressed() -> Void {
    }
	```

* call file selector via ```showFiles(withTokenProvider: showCloseButton: previouslySelectedFileID: delegate:)``` method
	```
	SQFilesAPI.sharedInstance().showFiles(withTokenProvider: SQOAuth.sharedInstance(),
                                  showCloseButton: true,
                                  previouslySelectedFileID: nil,
                                  delegate: self)
	```
	
	where
	```
	tokenProvider - provide SQOAuth instance (as SQOAuth.sharedInstance())
	showCloseButton - provide BOOL value to specify if you want to have Close button ability
	selectedFileID - provide file ID if you want to specific file be preselected
	delegate - provide UIViewController class instance that conforms to "SQFileSelectorProtocol" protocol
	```
	
* when user selects any file and clicks on "Continue" button in File Selector UI - ```selectedGeneticFile``` method from ```SQFileSelectorProtocol``` protocol will be called then.
	Selected file will be passed on as a parameter. In this method you can handle this selected file
	
	
* each file is a NSDictionary object with following keys and values format:
	
	key name | type | description
	------------- | ------------- | ------------- 
	DateAdded | String | date file was added
	Ext | String | file extension
	FileCategory | String | file category: Community, Uploaded, FromApps, Altruist
	FileSubType | String | file subtype
	FileType | String | file type
	FriendlyDesc1 | String | person name for sample files
	FriendlyDesc2 | String | person description for sample files
	Id | String | file ID
	Name | String | file name
	Population | String | 
	Sex | String |	the sex






Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Developer center](https://sequencing.com/developer-center)
* [Developer Documentation](https://sequencing.com/developer-documentation/)

Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
