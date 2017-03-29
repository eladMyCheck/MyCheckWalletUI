#
# Be sure to run `pod lib lint MyCheckWalletUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyCheckWalletUI'
  s.version          = '0.0.9'
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
  s.source           = { :git => 'https://bitbucket.org/erez_spatz/mycheckwalletui-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MyCheckWalletUI/Classes/*'
  
   s.resource_bundles = {
     'MyCheckWalletUI' => ['MyCheckWalletUI/Assets/*']
   }
s.requires_arc = 'true'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
s.dependency 'Alamofire', '~> 4.0'
 s.dependency 'Kingfisher', '~> 3.0'



s.default_subspec = 'Core'

s.subspec 'Core' do |core|
# the core. with no 3rd party wallets

end

s.subspec 'PayPal' do |paypal|
paypal.source_files = 'MyCheckWalletUI/Classes/paypal/**/*'

paypal.dependency 'Braintree/PayPal'
paypal.dependency 'Braintree/DataCollector'


end
s.subspec 'MasterPass' do |masterpass|
masterpass.source_files = 'MyCheckWalletUI/Classes/MasterPass/**/*'
end

end
