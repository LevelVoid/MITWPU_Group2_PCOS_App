require 'xcodeproj'
proj_path = 'PCOS_App.xcodeproj'
proj = Xcodeproj::Project.open(proj_path)

target_name = 'WorkoutWidgetExtension'
unless proj.targets.find { |t| t.name == target_name }
  # Create a new app extension target
  target = proj.new_target(:app_extension, target_name, :ios, '16.0')
  
  # Add frameworks
  frameworks = ['WidgetKit', 'SwiftUI', 'ActivityKit']
  frameworks.each do |fw_name|
    fw_ref = proj.frameworks_group.files.find { |f| f.path == "#{fw_name}.framework" }
    fw_ref ||= proj.frameworks_group.new_reference("System/Library/Frameworks/#{fw_name}.framework", :developer_dir)
    target.frameworks_build_phase.add_file_reference(fw_ref)
  end

  # Create group for extension files
  group = proj.main_group.groups.find { |g| g.name == target_name }
  group ||= proj.main_group.new_group(target_name, target_name)
  
  proj.save
  puts "Created target #{target_name}"
else
  puts "Target already exists"
end
