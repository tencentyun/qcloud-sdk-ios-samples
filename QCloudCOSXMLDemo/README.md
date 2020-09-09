# QCloudCOSXMLDemo

## demo简介
QCloudCOSXMLDemo 将展示对象存储基本功能，存储桶列表获取、存储桶的创建、文件上传、下载、删除、文件浏览等；

## 如何运行我们的 Demo
1. QCloudCOSXMLDemo 里采用了 cocoapods 的方式集成 SDK，您只需要在 Demo 的Podfile 所在目录中运行
    ```
    pod install
    ```

2. 然后打开对应的 xcworkspace 文件，在Key.json 文件中配置腾讯云账号 secretID，secretKey，appId；
>前往[控制台](https://console.cloud.tencent.com/cam/capi)查看账号信息。


3. 点击运行；
> 进入官网，快速体验示例[demo](https://cloud.tencent.com/document/product/436/18193)；

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
