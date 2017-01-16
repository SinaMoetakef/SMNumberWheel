#
# Be sure to run `pod lib lint SMNumberWheel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SMNumberWheel'
  s.version          = '1.0.0'
  s.summary          = 'SMNumberWheel is a subclass of UIControl written in Swift, which is ideal for picking numbers using a rotating wheel'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SMNumberWheel is a custom made control (subclass of UIControl) for iOS, written in Swift, which is ideal for picking numbers instead of typing them by software keyboards. The main idea is to be able to pick numbers very fast and and yet accurate. The wheel works with reading the angular speed of user's finger. The slower you spin the wheel, the more accurate values are resulted (up to 4 fraction digits accurate). The more rotation speed results in exponentially faster value changes.

features:
- Connection to code: Target Actions (drag to code) + Delegate methods.
- Reads user hand's movement speed, so that picking numbers are fast and also very accurate.
- Built-in buttons: Stepper buttons and central reset button
- Highly customizable through properties which results in thousands of different designs.
- Renders in InterfaceBuilder,  has customizable properties visible with Attributes Inspector (InterfaceBuilder)
- Supports sounds and haptic feedbacks (iPhone 7 and iPhone 7+)
                       DESC

  s.homepage         = 'https://github.com/SinaMoetakef/SMNumberWheel'
  # s.screenshots      = 'https://youtu.be/DIWpGOlDGOw', 'https://youtu.be/NTEsCepLYBY' , 'https://youtu.be/r_eG3oPFMfk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sina Moetakef' => 'sina.moetakef@gmail.com' }
  s.source           = { :git => 'https://github.com/SinaMoetakef/SMNumberWheel.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sina_motakef'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SMNumberWheel/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SMNumberWheel' => ['SMNumberWheel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
