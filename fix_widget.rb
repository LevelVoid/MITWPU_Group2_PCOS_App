require 'xcodeproj'
proj_path = 'PCOS_App.xcodeproj'
proj = Xcodeproj::Project.open(proj_path)

app_target = proj.targets.find { |t| t.name == 'PCOS_App' }
widget_target = proj.targets.find { |t| t.name == 'WorkoutWidgetExtension' }

# 1. Add files to the widget target's source build phase
group = proj.main_group.groups.find { |g| g.name == 'WorkoutWidgetExtension' }

live_activity_swift = group.files.find { |f| f.path == 'WorkoutLiveActivity.swift' }
unless live_activity_swift
  live_activity_swift = group.new_file('WorkoutLiveActivity.swift')
end
unless widget_target.source_build_phase.files_references.include?(live_activity_swift)
  widget_target.source_build_phase.add_file_reference(live_activity_swift)
end

# 2. Add WorkoutLiveActivityAttributes.swift to the widget target
attrs_swift = group.files.find { |f| f.path == '../PCOS_App/Workout/DataStore/WorkoutLiveActivityAttributes.swift' }
unless attrs_swift
  attrs_swift = group.new_file('../PCOS_App/Workout/DataStore/WorkoutLiveActivityAttributes.swift')
end
unless widget_target.source_build_phase.files_references.include?(attrs_swift)
  widget_target.source_build_phase.add_file_reference(attrs_swift)
end

# 3. Configure Info.plist and bundle identifier for widget target
widget_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'WorkoutWidgetExtension/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.pcosapp.WorkoutWidgetExtension'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
end

# 4. Embed the widget appex into the main app
embed_phase = app_target.copy_files_build_phases.find { |bp| bp.name == 'Embed App Extensions' || bp.symbol_dst_subfolder_spec == :plug_ins }
unless embed_phase
  embed_phase = app_target.new_copy_files_build_phase('Embed App Extensions')
  embed_phase.symbol_dst_subfolder_spec = :plug_ins
end

appex_ref = proj.products_group.files.find { |f| f.path == 'WorkoutWidgetExtension.appex' }
unless embed_phase.files_references.include?(appex_ref)
  build_file = embed_phase.add_file_reference(appex_ref)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

# 5. Make PCOS_App depend on WorkoutWidgetExtension
unless app_target.dependencies.any? { |d| d.target == widget_target }
  app_target.add_dependency(widget_target)
end

proj.save
puts "Successfully configured WorkoutWidgetExtension and embedded it into PCOS_App!"
