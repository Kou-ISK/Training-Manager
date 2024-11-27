//
//  TrainingMenuRow.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/11/22.
//

import SwiftUI

struct TrainingMenuRow: View {
    let menu: TrainingMenu
    let isEditMode: Bool
    let isCurrentTraining: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack {
            if isEditMode {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }

            VStack(alignment: .leading) {
                Text(menu.name).font(.headline)
                Text(menu.goal).font(.subheadline).underline()
                ForEach(menu.focusPoints, id: \.id) {
                    Text("・\($0.label)")
                }
                if let description = menu.menuDescription, !description.isEmpty {
                    Text(description).font(.caption).foregroundStyle(.gray)
                }
            }

            Spacer()

            if isEditMode {
                Button(action: onEdit) {
                    Text("編集").fontWeight(.bold).foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
            } else {
                VStack {
                    durationView
                    Button(action: onSelect) {
                        Text(isCurrentTraining ? "実施中" : "開始").fontWeight(.bold)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private var durationView: some View {
        HStack {
            Image(systemName: "stopwatch")
            Text(formatDuration(menu.duration ?? 0))
        }
        .foregroundStyle(.white)
        .fontWeight(.bold)
        .padding(5)
        .background(.green)
        .cornerRadius(30)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    // TrainingMenuRow()
}
