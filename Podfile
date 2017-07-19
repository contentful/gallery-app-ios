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

platform :ios, '8.0'

inhibit_all_warnings!

use_frameworks!

target 'Gallery' do
  pod 'ContentfulPersistenceSwift', :path => '~/Contentful/swift/SDK/contentful-persistence.swift', :branch => 'feature/wrapper'
  pod 'SOZOChromoplast'
  pod 'AlamofireImage', '~> 3.2'
end

target 'GalleryTests' do
  pod 'FBSnapshotTestCase', '~> 1.5'
end

