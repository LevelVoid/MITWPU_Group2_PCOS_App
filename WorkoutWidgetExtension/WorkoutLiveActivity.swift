import ActivityKit
import WidgetKit
import SwiftUI

@main
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutLiveActivityAttributes.self) { context in
            // Lock screen / banner UI
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.pink)
                Text(context.state.workoutName)
                    .font(.headline)
                Spacer()
                Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                    .multilineTextAlignment(.trailing)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.pink)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(.pink)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.workoutName)
                }
            } compactLeading: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.pink)
            } compactTrailing: {
                Text(timerInterval: context.state.startDate...context.state.endDate, countsDown: true)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
            } minimal: {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.pink)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.pink)
        }
    }
}
