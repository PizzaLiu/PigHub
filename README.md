# PigHub

A lite GitHub explorer of iOS.

[![Build Status](https://travis-ci.org/PizzaLiu/PigHub.svg?branch=master)](https://travis-ci.org/PizzaLiu/PigHub/)
[![](https://img.shields.io/github/release/PizzaLiu/PigHub.svg)](https://github.com/PizzaLiu/PigHub/releases)
![](https://img.shields.io/gratipay/pighub/shields.svg)
[![Gratipay](https://img.shields.io/gratipay/user/PizzaLiu.svg)](https://gratipay.com/~PizzaLiu/)

## How to get it

Download from App Store: https://itunes.apple.com/cn/app/pighub/id1202177372

or just search `PigHub` in App Store.

## How to build it

0. Get yourself a github api OAuth `Client ID` and `Client Secret` [here](https://github.com/settings/applications/new).
1. Clone this project to your disk: `$ git clone https://github.com/PizzaLiu/PigHub.git`.
2. Install dependencies in project root folder: `$ pod install`.
3. Put `Client ID` and `Client Secret` in `PigHub/Common/General/AppConfig.sample.h` and rename it to `PigHub/Common/General/AppConfig.h`
4. Open in latest Xcode (>=Xcode 8.2) then `Command` + `B` to build it.

## Screenshots

![Trending](_Screenshots/trending.png)
![Ranking](_Screenshots/ranking.png)
![Search](_Screenshots/search.png)
![My](_Screenshots/my.png)
![User](_Screenshots/user.png)
![Repo](_Screenshots/repo.png)

-------------

## Why is it called PigHub?

`PizzaLiu` + `GitHub` ~> `PizzaLiuGitHub` ~> `PitHub` ~> `PigHub`


## Todo

- [ ] Add gist module.
- [ ] Add notification push.
- [ ] Replace WebView in Repo Detail View to rendering markdown contents from api.
- [ ] Support spotlight.
- [ ] New app icon.

## Contributing

Contributors are more than welcome. Just upload a PR with a description of your changes.

If you would like to add more feature modules feel free to do so!

## Icons Copyrights

![code](PigHub/Assets.xcassets/Code20.imageset/code20.png) by arejoenah
![comment](PigHub/Assets.xcassets/Comment20.imageset/comment20.png) by AlePio
![eye](PigHub/Assets.xcassets/Eye20.imageset/eye20.png) by Dan Jenkins
![follow](PigHub/Assets.xcassets/Follow20.imageset/follow20.png) by carlos gonzalez
![following](PigHub/Assets.xcassets/Following20.imageset/following20.png) by carlos gonzalez
![fork](PigHub/Assets.xcassets/Fork20.imageset/fork.png) by Nick Bluth
![group](PigHub/Assets.xcassets/Group20.imageset/group20.png) by Luis Rodrigues
![heart](PigHub/Assets.xcassets/Heart20.imageset/heart20.png) by Lloyd Humphreys
![issue](PigHub/Assets.xcassets/Issue20.imageset/issue20.png) by Xinh Studio
![letter](PigHub/Assets.xcassets/Letter20.imageset/letter20.png) by Maxim Kulikov
![link](PigHub/Assets.xcassets/Link20.imageset/link20.png) by Viktor Vorobyev
![mark](PigHub/Assets.xcassets/Mark22.imageset/mark-bg.png) by Kimmi Studio
![merge](PigHub/Assets.xcassets/Merge20.imageset/merge20.png) by Bluetip Design
![okay](PigHub/Assets.xcassets/Okay.imageset/Okay.png) by Yasir B. Eryılmaz
![pin](PigHub/Assets.xcassets/Pin20.imageset/pin20.png) by Mahmure Alp
![push](PigHub/Assets.xcassets/Push20.imageset/push20.png) by Nick Bluth
![refresh](PigHub/Assets.xcassets/Refresh20.imageset/refresh20.png) by Amr Fakhri
![repo](PigHub/Assets.xcassets/Repository20.imageset/repository.png) by Sofía Moya

> All is under Creative Commons Attribution license.
> Thanks to [thenounproject.com](https://thenounproject.com)

## Licenses

All source code is licensed under the MIT License.
