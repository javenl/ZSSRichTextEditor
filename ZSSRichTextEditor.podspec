#
#  Be sure to run `pod spec lint ZSSRichTextEditor.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZSSRichTextEditor"
  s.version      = "0.6.2"
  s.summary      = "ZSSRichTextEditor is a beautiful Rich Text WYSIWYG Editor for iOS."

  s.description  = <<-DESC
`ZSSRichTextEditor` is a beautiful Rich Text `WYSIWYG Editor` for `iOS`. It includes all of the standard editor tools one would expect from a `WYSIWYG` editor as well as an amazing source view with syntax highlighting.
                   DESC

  s.homepage     = "https://github.com/javenl/ZSSRichTextEditor"
  s.screenshots  = "https://camo.githubusercontent.com/2bcf02776f39cae560c57793adbd5eaf4fff9223/687474703a2f2f662e636c2e6c792f6974656d732f304c3363304e337531343251325330763159306f2f64656d6f312e676966", "https://camo.githubusercontent.com/3f9c01eba9c69d030a69faaa1a2e01a733244627/687474703a2f2f636c2e6c792f696d6167652f3369343134303367323030422f64656d6f2e676966"

  s.license      = "MIT"
  
  s.author       = { "javen" => "412775083@qq.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "/Users/liu/Desktop/MyProjects/ZSSRichTextEditor/.git",
#:git => "https://github.com/javenl/ZSSRichTextEditor.git",
#:tag => "#{s.version}",
                     :sha1 => "1203b61d3afb7659c4ecedc3b9108568fae89565",
}

  s.source_files  = "**/*.{h,m}"
  s.exclude_files = "**/ZSSDemo*.{h,m}", "**/ZSSAppDelegate*.{h,m}", "**/main.m"
  s.resources = "**/ZSS*.png", "**/ZSSRichTextEditor.js", "**/ZSSExtend.js", "**/editor.html"

  s.vendored_libraries = 'ZSSRichTextEditor/Lame/libmp3lame.a'
  s.libraries = "mp3lame"

  s.frameworks = "CoreGraphics", "CoreText", "MobileCoreServices", "AssetsLibrary"

  s.requires_arc = true
end
