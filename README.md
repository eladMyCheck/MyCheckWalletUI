# MyCheckWalletUI
An SDK that supplies UI for payment method managment.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. The example demonstrates displaying a Checkout view controller , displaying a payment manager view controller and getting the token when ready to pay.

## Requirements
iOS 9 or above.
Swift 3.0

## Installation

MyCheckWalletUI is available through [CocoaPods](http://cocoapods.org). You will first need to ask a MyCheck team member to give you read privileges to the MyCheck Repository. Once you have gotten the privileges, install
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
In order to manage the users session (login, logout etc.) you will need to use the session singleton.

Start by adding
```
import MyCheckCore
```


to the top of the class where you want to use MyCheck.

In your app delegate's `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)` function call the configure function of the Session singleton:

```
Session.shared.configure(YOUR_PUBLISHABLE_KEY, environment: .sandbox)
```
This will setup the SDK to work with the desired environment.

Before using any other functions you will have to login the user. Login is done by first obtaining a refresh token from your server (that, in turn, will obtain it from the MyCheck server using the secret). Once you have the refresh token call the login function on the Session singleton:


```
Session.shared.login(REFRESH_TOKEN, success: HANDLE_SUCCESS
}, fail: HANDLE_FAIL)

```
Once you are logged in add
```
import MyCheckWalletUI
```
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
## PayPal
Their are a few extra steps to take in order for PayPal to work.
Start by installing the PayPal model. This will add the Braintree PayPal SDK as well as extra source files from the MyCheck Wallet UI SDK. Add this line to your Podfile:

```
pod "MyCheckWalletUI/PayPal"
```
once this is done you will need to also add a line of code initializing the PayPal model. 
```
PaypalFactory.initiate(YOUR_PACKAGE_NAME)
```
The last line of code necessary is to allow the MyCheck Wallet UI SDK to respond to  app switching. This is necessary because the PayPal SDK opens an external app/ browser. 
```

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

return MyCheckWallet.shared.handleOpenURL(url, sourceApplication: sourceApplication)

}
```

Lastly, to fully support PayPal and the app switching it uses please edit your info.plist  as described in the "Register a URL type" section of the [PayPal Braintree SDK guide found here](https://developers.braintreepayments.com/guides/paypal/client-side/ios/v4).

## Apple Pay
Their are a few extra steps to take in order for Apple Pay to work.
Start by configuring your environment to support Apple Pay by following [these instructions](https://developer.apple.com/library/content/ApplePay_Guide/Configuration.html#//apple_ref/doc/uid/TP40014764-CH2-SW1).  Send the certificate you have created to a member of the MyCheck team. 
now install the Apple Pay model of the MyCheckWalletUI SDK by adding this line to your Podfile:

```
pod "MyCheckWalletUI/ApplePay"
```
After running `pod install`  you will need to also add a line of code initializing the Apple Pay model with the merchant identifier you have created in the apple developers site in the last step . 
```
ApplePayFactory.initiate(merchantIdentifier: YOUR_MERCHANT_ID)
```
The line of code above should be added in the  `application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)` function of your application delegate after calling configure. Thats it for now. You will need to make a few more changes to add Apple Pay support to the Dine SDK, this is discussed in the Dine SDK README file and getting started guide.


## Authors

Elad Schiller, eladsc@mycheckapp.co.il
## License

Please read the LICENSE file available in the project


