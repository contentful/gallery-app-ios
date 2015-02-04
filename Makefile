.PHONY: all setup storyboard_ids

all:
	xcodebuild -workspace 'Gallery.xcworkspace' -scheme 'Gallery'|xcpretty

setup:
	bundle install
	bundle exec pod install

storyboard_ids:
	bundle exec sbconstants --swift Code/StoryboardIdentifiers.swift
