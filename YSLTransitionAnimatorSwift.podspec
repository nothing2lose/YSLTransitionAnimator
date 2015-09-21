@version = "0.0.2"
Pod::Spec.new do |s|
  s.name         = "YSLTransitionAnimatorSwift"
  s.version      = @version
  s.summary      = "a pinterest style transition animation"
  s.homepage     = "https://github.com/y-hryk/YSLTransitionAnimator"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "y-hryk" => "dev.hy630823@gmail.com" }
  s.source       = { :git => "https://github.com/nothing2lose/YSLTransitionAnimator", :tag => @version }
  s.source_files = 'YSLTransitionAnimatorSwift/**/*.{swift}'
  s.resources = 'YSLTransitionAnimator/Resources/*.png'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
end
