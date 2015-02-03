.PHONY: all setup storyboard_ids

all:
	xcodebuild -workspace 'Blog.xcworkspace' -scheme 'Blog'|xcpretty

setup:
	bundle install
	bundle exec pod install

storyboard_ids:
	bundle exec sbconstants --swift Code/StoryboardIdentifiers.swift
