require 'xcodeproj'
proj_path = 'PCOS_App.xcodeproj'
proj = Xcodeproj::Project.open(proj_path)

widget_target = proj.targets.find { |t| t.name == 'WorkoutWidgetExtension' }

widget_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = 'WorkoutWidgetExtension'
  config.build_settings['DEVELOPMENT_TEAM'] = '474MDX8R3T'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
end

proj.save
puts "Fixed build settings!"
