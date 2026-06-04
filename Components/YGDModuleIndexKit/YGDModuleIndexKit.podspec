Pod::Spec.new do |s|
  s.name = 'YGDModuleIndexKit'
  s.version = '0.1.0'
  s.summary = 'Feature module index bootstrap for pigAreFlying.'
  s.homepage = 'https://github.com/best-pig/YGDModuleIndexKit'
  s.license = { :type => 'MIT', :text => 'MIT License' }
  s.author = { 'yangchengcheng' => 'yangchengcheng@example.com' }
  s.source = { :git => 'https://github.com/best-pig/YGDModuleIndexKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  s.dependency 'YGDModuleBridgeKit'
  s.dependency 'YGDTodayModule'
  s.dependency 'YGDTasksModule'
  s.dependency 'YGDFocusModule'
  s.dependency 'YGDInsightsModule'
  s.dependency 'YGDSettingsModule'
end
