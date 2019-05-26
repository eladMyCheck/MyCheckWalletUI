#
# Be sure to run `pod lib lint MyCheckWalletUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyCheckWalletUI'
  s.version          = '1.2.6'
  s.summary          = 'An SDK that supplies UI for payment method managment.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'README.md'

s.homepage         = 'https://mycheckapp.com'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'elad schiller' => 'eladsc@mycheck.co.il' }
s.source           = { :git => 'https://github.com/mycheck888/MyCheckWalletUI.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '9.0'



s.requires_arc = 'true'

# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'
s.dependency 'MyCheckCore'
s.dependency 'Kingfisher'



s.default_subspec = 'Core'

s.subspec 'Core' do |core|
# the core. with no 3rd party wallets
core.source_files = 'MyCheckWalletUI/Classes/*' , 'MyCheckWalletUI/Classes/ViewControllers/**/*' ,'MyCheckWalletUI/Classes/extensionTools/*' ,'MyCheckWalletUI/Classes/interfaces/*' ,'MyCheckWalletUI/Classes/extensions/*'

core.resource_bundles = {
'MyCheckWalletUI' => ['MyCheckWalletUI/Assets/*']
}

end

s.subspec 'MasterPass' do |masterpass|
masterpass.ios.deployment_target = '9.0'
masterpass.platform = :ios, '9.0'

masterpass.source_files = 'MyCheckWalletUI/Classes/MasterPass/**/*'
masterpass.dependency 'MyCheckWalletUI/Core'

end

s.subspec 'ApplePay' do |applepay|
applepay.dependency 'MyCheckWalletUI/Core'
applepay.frameworks = 'PassKit'

applepay.source_files = 'MyCheckWalletUI/Classes/ApplePay/**/*'
applepay.ios.deployment_target = '9.0'
applepay.platform = :ios, '9.0'

end


s.subspec 'VisaCheckout' do |visacheckout|
visacheckout.dependency 'MyCheckWalletUI/Core'

visacheckout.dependency 'VisaCheckoutSDK'
visacheckout.source_files = 'MyCheckWalletUI/Classes/VisaCheckout/*'
visacheckout.ios.deployment_target = '9.0'
visacheckout.platform = :ios, '9.0'
end

s.subspec 'PayPal' do |paypal|
paypal.dependency 'MyCheckWalletUI/Core'

paypal.dependency 'Braintree/PayPal'
paypal.dependency 'Braintree/DataCollector'

paypal.source_files = 'MyCheckWalletUI/Classes/paypal/**/*'
paypal.ios.deployment_target = '9.0'
paypal.platform = :ios, '9.0'

end

end


