# MyCheckWallet

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The Example has no app, but it does have a unit test that calls all the functions and demonstrates the use.

## Requirements
iOS 8 or above.

## Installation

MyCheckWallet is available through [CocoaPods](http://cocoapods.org). You will first need to ask a MyCheck team member to give you read privligeas to the MyCheck Repository. Once you have gotten the privileges, install
it by simply adding the following lines to the top of your Podfile:

## Use
Use the MyCheckWallet singlton object. Before all other functions you must call the login function. Detailed documentation of the classes functionality and use can be found in the API Docs.
```ruby
source 'https://bitbucket.org/eladsc/pod-spec-repo.git'
source 'https://github.com/CocoaPods/Specs.git'
```
You can add YOUR_USER_ANEM@ before the 'bitbucket.org' so the pod tool won't need to ask you for it every time you update or install.
This will set both the public CocoaPods Repo and the MyCheck private repo as targets for CocoaPods to search for frameworks.

inside the target add

```ruby
pod "MyCheckWallet"
```
Now you can run 'pod install'

## Author

Elad Schiller, eladsc@mycheck.co.il

## License

Please read the LICENSE file available in the project
