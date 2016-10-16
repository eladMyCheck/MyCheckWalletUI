# MyCheckWalletUI
An SDK that supplies UI for payment method managment.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The example demonstrates displaying a Checkout view controller , displaying a payment manager view controller and getting the token when ready to pay.

## Requirements
iOS 8 or above.

## Installation

MyCheckWallet is available through [CocoaPods](http://cocoapods.org). You will first need to ask a MyCheck team member to give you read privileges to the MyCheck Repository. Once you have gotten the privileges, install
it by simply adding the following lines to the top of your Podfile:

```
source 'https://bitbucket.org/erez_spatz/pod-spec-repo.git'
source 'https://github.com/CocoaPods/Specs.git'
```
This will set both the public CocoaPods Repo and the MyCheck private repo as targets for CocoaPods to search for frameworks from.

You can add YOUR_USER_NAME@ before the 'bitbucket.org' so the pod tool won't need to ask you for it every time you update or install.

inside the target add:

```
pod "MyCheckWalletUI"
```
Now you can run 'pod install'

## Use
Start by adding
```
import MyCheckWalletUI
```

to the top of the class where you want to use MyCheckWallet.

Before displaying any UI you will have to login. Login by using the MyCheckWallet singelton.


```
MyCheckWallet.manager.login(YOUR_REFRESH_TOKEN, publishableKey: YOUR_PUBLISHABLE_KEY, success: {
    //handle success
} , fail: { error in
    //handle failure
})
```
Once you are logged in you can display the MyCheck UI. We have two UI elements

###MCCheckoutViewController
This view controller is meant to be embedded inside your view controller. It allows the user the basic functions needed from a wallet:
  1. Add a credit card
  2. Select a credit card
The view controller should be added into a container view. It can be done in two ways.

  1. Interface builder: change the view controller that the container is connect to (by segue) to `MCCheckoutViewController`. 
  2. In code: call MCCheckoutViewController.init() in order to create the instance.

Once an instance is created you should set `checkoutDelegate` and implement  `checkoutViewShouldResizeHeight` in order to respond to height changes. You should resize the container view to have the height returned by the delegate method.
When you want to use a payment method use the view controllers variable `selectedMethod` in order to get the method the user selected (or nil if nonexistent) 

###MCPaymentMethodsViewController
This class is a full screen view controller that allows the user to fully manage his/her payment methods:

  1. Display all his/her payment methods.
  2. Choose a default payment method.
  3. Delete payment methods.
  4. Add payment methods.

In order to create a MCPaymentMethodsViewController instance call the constructor and present it like so:

```
let controller = MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
self.presentViewController(controller, animated: true, completion: nil)

```

You must also implement the MCPaymentMethodsViewControllerDelegate and dismiss the view controller when it is done 
example

```

func dismissedMCPaymentMethodsViewController(controller: MCPaymentMethodsViewController){
controller.dismissViewControllerAnimated(true, completion: nil)
}

```

## Authors

Elad Schiller, eladsc@mycheckapp.com
Mihail Kalichkov, mihailk@mycheckapp.com 
## License

Please read the LICENSE file available in the project




