Pod::Spec.new do |s|

  s.name         = "KINavigationController"
  s.version      = "1.0.0"
  s.summary      = "三种popViewController的效果,例如淘宝、京东的“整体返回”效果"

  s.homepage     = "https://github.com/xinyuly/KINavigationController"
  s.license      = "MIT"
  s.author       = {"lixinyu" => 'li_xinyuly@163.com'}

  s.ios.deployment_target = "8.0"

  s.source       = { :git => 'https://github.com/xinyuly/KINavigationController.git', :tag => s.version }

  s.source_files  = "KINavigationController/*.swift"
  s.requires_arc = true

 s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

end
