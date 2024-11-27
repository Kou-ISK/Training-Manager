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
    
    @State private var isExpanded: Bool = false // 詳細表示の状態を管理
    
    var body: some View {
        VStack {
            HStack {
                TrainingMenuRowHeader(menu: menu, isEditMode: isEditMode, isCurrentTraining: isCurrentTraining, onDelete: onDelete, onEdit: onEdit, onSelect: onSelect)
                Button(action: { isExpanded.toggle() }, label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right").padding(4)
                }).buttonStyle(.borderless)
            }
            
            if isExpanded { // 展開状態のときに詳細を表示
                VStack(alignment: .leading) {
                    if !menu.goal.isEmpty {
                        Text("練習のゴール:")
                            .font(.headline)
                        Text(menu.goal)
                            .font(.body)
                            .padding(.bottom, 4)
                    }
                    if !menu.focusPoints.isEmpty {
                        Text("フォーカスポイント:")
                            .font(.headline)
                        ForEach(menu.focusPoints, id: \.self) { point in
                            Text(point.label)
                                .font(.body)
                        }
                        .padding(.bottom, 4)
                    }
                    if let description = menu.menuDescription, !description.isEmpty {
                        Text("備考:")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(isCurrentTraining ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)) // 背景色を適用
        .cornerRadius(8) // 背景色の角を丸める
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrentTraining ? Color.blue : Color.gray, lineWidth: 1) // 境界線を追加
        )
    }
}

#Preview {
    TrainingMenuRow(menu: TrainingMenu(name: "Name", goal: "Goal", duration: TimeInterval(100), focusPoints: ["FP"], menuDescription: "Description", orderIndex: 1), isEditMode: false, isCurrentTraining: true, onDelete: {print("Save")}, onEdit: {print("Delete")}, onSelect: {print("Select")})
}
