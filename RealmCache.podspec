Pod::Spec.new do |s|
  s.name                    = "RealmCache"
  s.version                 = "0.1.1"
  s.summary                 = "RealmCache is like NSCache but persistent and built with Realm"
  s.description             = <<-DESC
                              RealmCache is like NSCache but persistent and built with Realm
                              DESC
  s.homepage                = "https://github.com/alexanderjarvis/realmcache"
  s.source                  = { :git => 'https://github.com/alexanderjarvis/realmcache', :tag => "v#{s.version}" }
  s.author                  = { "Alex Jarvis" => "alex@panaxiom.co.uk" }
  s.requires_arc            = true
  s.license                 = 'MIT'

  s.dependency 'RealmSwift', '~> 0.95.0'
  s.source_files = 'RealmCache/*.swift'

  s.ios.deployment_target   = '8.0'
end
