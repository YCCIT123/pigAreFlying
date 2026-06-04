Pod::Spec.new do |s|
  s.name = 'YGDModuleBridgeKit'
  s.version = '0.1.0'
  s.summary = 'Feature module bridge contracts for pigAreFlying.'
  s.homepage = 'https://github.com/best-pig/YGDModuleBridgeKit'
  s.license = { :type => 'MIT', :text => 'MIT License' }
  s.author = { 'yangchengcheng' => 'yangchengcheng@example.com' }
  s.source = { :git => 'https://github.com/best-pig/YGDModuleBridgeKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  s.dependency 'YGDCoreKit'
  s.dependency 'YGDRouterKit'
end
