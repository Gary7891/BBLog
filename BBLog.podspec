Pod::Spec.new do |s|
  s.name         = "BBLog"
  s.version      = "0.0.6"
  s.summary      = "iOS日志采集和上传组件"
  s.homepage     = "https://git.tticar.com/pods/BBLog"
  s.license      = "Copyright (C) 2018 Gary, Inc.  All rights reserved."
  s.author             = { "Gary" => "zguanyu@163.com" }
  s.social_media_url   = "http://www.cupinn.com"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://git.tticar.com/pods/BBLog.git"}
  s.source_files  = "BBLog/BBLog/**/*.{h,m,c}"
  s.requires_arc = true
  s.dependency 'Realm'
end
