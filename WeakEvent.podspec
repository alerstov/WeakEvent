Pod::Spec.new do |s|
  s.name             = "WeakEvent"
  s.version          = "0.1.0"
  s.summary          = "Block based event system"
  s.homepage         = "https://github.com/alerstov/WeakEvent"
  s.license          = 'MIT'
  s.author           = { "Alexander Stepanov" => "alerstov@gmail.com" }
  s.source           = { :git => "https://github.com/alerstov/WeakEvent.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'WeakEvent/*.{h,m}'
end
