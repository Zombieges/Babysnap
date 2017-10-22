# Uncomment this line to define a global platform for your project
#platform :ios, ‘10.0’
use_frameworks!

target 'Babysnap' do
    pod 'RealmSwift'
    pod 'GPUImage'
    pod ‘SwiftyJSON’
    pod 'SVProgressHUD'
end

post_install do |installer|
    #installer.pods_project.build_configuration_list.build_configurations.each do |configuration|        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    #end
        
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "3.0"
            #target.build_configuration_list.set_setting('HEADER_SEARCH_PATHS', '')
        end
    end
end
