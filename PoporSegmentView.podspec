#
# Be sure to run `pod lib lint PoporSegmentView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PoporSegmentView'
  s.version          = '1.12'
  s.summary          = '一组 UIButton 左右滑动,并且与外部的 UIScrollView 保持联动.'

  s.homepage         = 'https://github.com/popor/PoporSegmentView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'popor' => '908891024@qq.com' }
  s.source           = { :git => 'https://github.com/popor/PoporSegmentView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Example/Classes/*.{h,m}'
  
  s.dependency 'Masonry'
  s.dependency 'PoporMasonry'
  
end
