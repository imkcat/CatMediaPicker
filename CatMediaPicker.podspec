#
# Be sure to run `pod lib lint CatMediaPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CatMediaPicker'
  s.version          = '0.1.0'
  s.summary          = 'Picking easier.'
 s.description      = <<-DESC
 CatMediaPicker is a media picker for easy to use.
                      DESC
  s.homepage         = 'https://github.com/ImKcat/CatMediaPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kcat' => 'kcatdeveloper@icloud.com' }
  s.source           = { :git => 'https://github.com/ImKcat/CatMediaPicker.git', :tag => s.version.to_s }
  s.social_media_url = 'https://imkcat.com'

  s.ios.deployment_target = '9.0'
  
  s.requires_arc = true
  s.source_files = 'Sources/**/*.{h,c,swift}'
end
