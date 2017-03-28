# File Selector CocoPod plugin for adding Sequencing.com's Real-Time Personalization technology to iOS apps coded in Swift
=========================================
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
	pod 'sequencing-file-selector-api-swift', '~> 2.0.1'
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



### Step 3: Set up file selector UI

* add "Storyboard Reference" in your Main.storyboard
	* open your main storyboard
	* add "Storyboard Reference" object
	* select added "Storyboard Reference"
	* open Utilities > Atributes inspector
	* select ```TabbarFileSelector``` in Storyboard dropdown
		
* add segue from your ViewController to created Storyboard Reference
	* open Utilities > Atributes inspector
	* name this segue as ```GET_FILES``` in Identifier field
	* set Kind as ```Present Modally```
		
* add all resources of ```File Selector``` plugin into your project Bundle Resources:
	* select project name
	* select project target
	* open ```Build Phases``` tab
	* expand ```Copy Bundle Resources``` phase
	* click ```Add Items``` button ("+" icon)
	* click ```Add Other``` button
	* open your project folder
	* open ```Pods``` subfolder
	* open ```sequencing-oauth-api-swift``` subfolder
	* open ```Resources``` subfolder 
	
	* add ```TabbarFileSelector.storyboard``` storyboard
	* add ```SQFilesPopoverInfoViewController.xib``` popover nib
	* add ```SQFilesPopoverMyFilesViewController.xib``` popover nib
	* add ```Images.xcassets``` xcassets
	
	
### Step 4: Set up file selector plugin in code
		
* add import: 

	```
	import sequencing_file_selector_api_swift
	```

* subscribe your class to file selector protocol: 

	```
	SQFileSelectorProtocol
	```
		
* add property for SQFilesAPI class
	
	```
	let filesApiHelper = SQFilesAPI.instance
	```
	
* subscribe your class as handler/delegate for selected file in file selector: 

	```
	self.filesApiHelper.selectedFileDelegate = self
	```
		
* implement "handleFileSelected" method from ```SQFileSelectorProtocol``` protocol

	```
	func handleFileSelected(_ file: NSDictionary) -> Void {
		// your code here
    }
	```

* implement optional "closeButtonPressed" method from protocol if needed

	```
	func closeButtonPressed() -> Void {
        // your code here
    }
	```
	

	
### Step 5: Use file selector 

* set up some button for getting/viewing files for logged in user, and specify delegate method for this button
	
* specify segue ID constant for file selector UI

	```
	let FILES_CONTROLLER_SEGUE_ID = "GET_FILES"
	```	
		
* you can load/get files, list of my files and list of sample files, via ```withToken: loadFiles:``` method (via ```SQFilesAPI``` class with shared instance init access).
	
	pay attention, you need to pass on the String value of ```token.accessToken``` object as a parameter for this method:
	
	```
	self.filesApiHelper.loadFilesWithToken(self.token!.accessToken as NSString, success: { (success) in
		DispatchQueue.main.async {
			// your code here
		}
	})
	```
		
	```loadFilesWithToken``` method will return a Bool value with ```true` if files were successfully loaded or ```false``` if there were any problem. You need to manage this in your code
		
		
* if files were loaded successfully you can now open/show File Selector in UI. You can do it by calling File Selector view via ```performSegueWithIdentifier``` method:

	```
	self.performSegue(withIdentifier: self.FILES_CONTROLLER_SEGUE_ID, sender: nil)
	```
	
	while opening File Selector in UI you can set `Close` button to be present if you need
	
	```
	self.filesApiHelper.closeButton = true
	```
	
* when user selects any file and clicks on "Continue" button in File Selector UI - ```handleFileSelected``` method from ```SQFileSelectorProtocolDelegate``` protocol will be called then. Selected file will be passed on as a parameter. In this method you can handle this selected file
	
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


### Step 6: Examples 

* example of ```File Selector - Intro page```

	![intro page](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC/blob/master/Screenshots/fileSelector_introPage.png)


* example of ```File Selector - My Files```

	![my files](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC/blob/master/Screenshots/fileSelector_myFiles2.png)


* example of ```Sample Files```

	![sample files](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC/blob/master/Screenshots/fileSelector_sampleFiles2.png)

	
* example of selected file

	![selected file](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC/blob/master/Screenshots/fileSelector_sampleFiles2selected.png)

	
* example of ```Select File``` button - you can add simple button via storyboard
	
	
* example of delegate method for select file button

	```
	@IBAction func loadFilesButtonPressed(_ sender: AnyObject) {
	
        self.view.isUserInteractionEnabled = false
        self.startActivityIndicatorWithTitle("Loading Files")
        if self.token != nil {
            self.filesApiHelper.loadFilesWithToken(self.token!.accessToken as NSString, success: { (success) in
            
            	DispatchQueue.main.async {
            		if success {
                        self.stopActivityIndicator()
                        self.view.isUserInteractionEnabled = true
                        self.performSegue(withIdentifier: self.FILES_CONTROLLER_SEGUE_ID, sender: nil)
                        
                    } else {
                        self.stopActivityIndicator()
                        self.view.isUserInteractionEnabled = true
                        self.showAlertWithMessage("Sorry, can't load genetic files")
                    }
            	}
            })
        } else {
        	self.stopActivityIndicator()
            self.showAlertWithMessage("Sorry, can't load genetic files > token is empty")
        }
    }
	```	


* example of ```handleFileSelected``` method

	```
	func handleFileSelected(_ file: NSDictionary) -> Void {
        self.dismiss(animated: true, completion: nil)
        print(file)
        
        DispatchQueue.main.async {
        	if file.allKeys.count > 0 {
	        	self.stopActivityIndicator()
                self.view.isUserInteractionEnabled = true
                self.selectedFile = file    	
        	} else {
	        	self.stopActivityIndicator()
                self.view.isUserInteractionEnabled = true
                self.showAlertWithMessage("Sorry, can't load genetic files")
        	}
        }
    }
	```

* example of ```closeButtonPressed``` method

	```
	func closeButtonPressed() -> Void {
		self.stopActivityIndicator()
        self.dismiss(animated: true, completion: nil)
    }
	```



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
