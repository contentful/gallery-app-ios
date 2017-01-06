=begin
Use cocoapod-keys to load application keys (variables).
See https://github.com/orta/cocoapods-keys.
=end

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

use_frameworks!

target 'Gallery' do
  pod 'Bypass', '~> 1.0.1'
  pod 'Contentful'
  pod 'ContentfulDialogs', :git => 'git@github.com:contentful/contentful-ios-dialogs.git'
  pod 'ContentfulPersistenceSwift', '>= 0.2.0'
  pod 'ContentfulStyle'
  pod 'KVOController'
#pod 'LatoFont'
  pod 'SOZOChromoplast'
  pod 'ZoomInteractiveTransition', :git => 'https://github.com/neonichu/ZoomInteractiveTransition.git',
    :branch => 'reset-alpha-after-animation'
end

target 'GalleryTests' do
  pod 'FBSnapshotTestCase', '~> 1.5'
end

