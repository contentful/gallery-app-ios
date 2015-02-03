# Gallery

This is an iOS application example for the [Contentful][1] gallery space template.

[Contentful][1] is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Usage

- Create a space with the "Gallery" space template on [Contentful][1]
- Clone this repo and setup [CocoaPods][2] for it:

```
$ make setup
```

- Use cocoapods-keys to setup your space credentials for it:

```
$ bundle exec pod keys set GallerySpaceId $YOUR_SPACE_ID
$ bundle exec pod keys set GalleryAccessToken $YOUR_ACCESS_TOKEN
```

- Now you're ready to use it!

## Customizing

- You can easily drop the [Contentful][1] related branding by removing 'ContentfulDialogs' and 'ContentfulStyle' from the Podfile. You will need to remove the `addInfoButton()` function from the `UIViewController` extension, as well as replace usages of our fonts and colors. In addition to that, update the bridging header as there are now some header files missing.

- The app has support for the 'contentful-gallery://' custom URL scheme, you should also remove that if you are using the template for your own application.

## License

Copyright (c) 2015 Contentful GmbH. See LICENSE for further details.


[1]: https://www.contentful.com
[2]: http://cocoapods.org
