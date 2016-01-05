plugin 'cocoapods-keys', {
  :project => 'Gallery',
  :keys => [
    'GallerySpaceId',
    'GalleryAccessToken'
  ]}

source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/contentful/CocoaPodsSpecs'

platform :ios, '8.0'

inhibit_all_warnings!

#use_frameworks!

pod 'Bypass', '~> 1.0.0'
pod 'ContentfulDeliveryAPI', '~> 1.9.0'
pod 'ContentfulDialogs', '~> 0.4.0'
pod 'ContentfulPersistence', '>= 0.3.2'
pod 'ContentfulStyle', :head
pod 'KVOController', '~> 1.0.0'
pod 'SOZOChromoplast', '~> 0.0.2'
pod 'ZoomInteractiveTransition', :git => 'https://github.com/neonichu/ZoomInteractiveTransition.git',
	:branch => 'reset-alpha-after-animation'

target 'GalleryTests', :exclusive => true do

pod 'FBSnapshotTestCase', '~> 1.5'

end

