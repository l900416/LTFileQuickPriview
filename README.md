# LTFileQuickPriview
Support both online and local document &amp; Multi-Media File Preview. Easy to use. 

![](https://github.com/l900416/LTFileQuickPriview/blob/master/Screenshots/1.png)

## Features   
* Support QuickLook Type File    
* Support Web Page    
* Support Multi-Media File   
* Custom UI   
* File cache

## Upcoming features    
* to be continue


## Installation with CocoaPods

LTFileQuickPreview is available in CocoaPods, specify it in your *Podfile*:

    pod 'LTFileQuickPreview'

## Requirements

    iOS 9+

## Usage

Easy to use, all you need to do is: 

> init the viewController with file dataSource.

> push or show the viewController.

That's all.

```Objective-C
    //init
    LTQuickPreviewViewController* quickPreviewVC = [LTQuickPreviewViewController 
                                                        instanceWithURL:url];

    //push or show
    [self.navigationController pushViewController:quickPreviewVC animated:true];

```

## License

LTFileQuickPreview is available under the **MIT** license. See the LICENSE file for more info.
