#!/usr/bin/ruby

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
#source 'https://github.com/contentful/CocoaPodsSpecs'

use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!

target 'Gallery' do

  pod 'ContentfulPersistenceSwift', '~> 0.12.0'
  pod 'AlamofireImage', '~> 3.3'
  pod 'markymark'
  pod 'ContentfulDialogs', :git => 'https://github.com/contentful/contentful-ios-dialogs.git'

  target 'GalleryTests' do
    inherit! :search_paths
    pod 'FBSnapshotTestCase', '~> 1.5'
  end
end


