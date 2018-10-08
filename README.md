# 腾讯云 存储SDK Demo for iOS
这里包含了腾讯云存储 SDK for iOS
# Demo 列表
当前的产品有
- COS XML 开箱即用示例(OOTB-XML)
- 基于 COS XML API 封装的 SDK （V5 SDK）
- 基于 COS JSON API 封装的 SDK (V4 SDK, 不建议新接入用户使用，推荐使用V5的SDK)
- 腾讯移动开发平台（MobileLine）
# 如何运行我们的 Demo
本仓库包含了 iOS 版本的腾讯云存储 SDK 的 Demo，您可以下载具体的具体的Demo来进行体验。Demo 里采用了 cocoapods 的方式集成 SDK，您只需要在 Demo 的Podfile 所在目录中运行
```
pod install
```
然后打开对应的 xcworkspace 文件，即可运行我们的 Demo。    
> 对于 MoblieLine 的 Demo, 还需要加入配置文件后运行，详细操作可以参考官网文档。
# License
腾讯云存储 SDK for iOS 以及 Demo 都通过 MIT License 发布。    
Tencent Cloud SDK for iOS and samples are released under the MIT license.
~~~
Copyright (c) 2017 腾讯云

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
~~~
