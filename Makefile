# read value from Contentful configuration
get_config = $(shell grep -A 2 $1 ~/.contentfulrc|grep $2|cut -d' ' -f3)

.PHONY: all bootstrap setup storyboard_ids

SPACE_NAME=my_gallery

all:
	xcodebuild -workspace 'Gallery.xcworkspace' -scheme 'Gallery'|xcpretty

bootstrap:
	bundle install
	bundle exec contentful_bootstrap create_space $(SPACE_NAME) -j Templates/gallery.json

setup: bootstrap
	@pod keys set GallerySpaceId $(call get_config,$(SPACE_NAME),SPACE_ID)
	@pod keys set GalleryAccessToken $(call get_config,$(SPACE_NAME),CONTENTFUL_DELIVERY_ACCESS_TOKEN)
	bundle exec pod install #--no-repo-update

storyboard_ids:
	bundle exec sbconstants --swift Code/StoryboardIdentifiers.swift
