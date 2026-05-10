require 'xcodeproj'
proj_path = 'PCOS_App.xcodeproj'
proj = Xcodeproj::Project.open(proj_path)

widget_target = proj.targets.find { |t| t.name == 'WorkoutWidgetExtension' }

widget_target.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.2'
end

proj.save
puts "Fixed deployment target!"
