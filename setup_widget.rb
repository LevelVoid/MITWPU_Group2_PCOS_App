require 'xcodeproj'
proj_path = 'PCOS_App.xcodeproj'
proj = Xcodeproj::Project.open(proj_path)

target_name = 'WorkoutWidgetExtension'
app_target = proj.targets.find { |t| t.name == 'PCOS_App' }
widget_target = proj.targets.find { |t| t.name == target_name }

group = proj.main_group.groups.find { |g| g.name == target_name }

# Create files if they don't exist
Dir.mkdir(target_name) unless Dir.exist?(target_name)

files_to_add = ['WorkoutLiveActivity.swift', 'Info.plist']
file_refs = []

files_to_add.each do |filename|
  file_path = File.join(target_name, filename)
  File.write(file_path, "") unless File.exist?(file_path)
  
  ref = group.files.find { |f| f.path == filename }
  ref ||= group.new_file(filename)
  file_refs << ref
  
  if filename.end_with?('.swift')
    widget_target.source_build_phase.add_file_reference(ref) unless widget_target.source_build_phase.files_references.include?(ref)
  end
end

# Also add WorkoutLiveActivityAttributes.swift to the widget target so it can see the attributes
attrs_ref = proj.main_group.find_subpath('PCOS_App/Workout/DataStore/WorkoutLiveActivityAttributes.swift')
if attrs_ref
  widget_target.source_build_phase.add_file_reference(attrs_ref) unless widget_target.source_build_phase.files_references.include?(attrs_ref)
end

# Set Build Settings
widget_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = "#{target_name}/Info.plist"
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.pcosapp.WorkoutWidgetExtension" # You should use the app's bundle ID prefix, let's assume this or standard
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
end

# Embed in main app
embed_phase = app_target.copy_files_build_phases.find { |bp| bp.name == 'Embed Foundation Extensions' || bp.symbol_dst_subfolder_spec == :plug_ins }
unless embed_phase
  embed_phase = app_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end

appex_ref = proj.products_group.files.find { |f| f.path == "#{target_name}.appex" }
unless embed_phase.files_references.include?(appex_ref)
  build_file = embed_phase.add_file_reference(appex_ref)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

# Add target dependency
unless app_target.dependencies.any? { |d| d.target == widget_target }
  app_target.add_dependency(widget_target)
end

proj.save
puts "Widget target configured fully."
