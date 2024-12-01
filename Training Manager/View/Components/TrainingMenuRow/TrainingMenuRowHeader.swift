//
//  TrainingMenuRowHeader.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/11/27.
//

import SwiftUI

struct TrainingMenuRowHeader: View {
    @Environment(\.colorScheme) var colorScheme
    
    let menu: TrainingMenu
    let isEditMode: Bool
    let isTodaySession: Bool
    let isCurrentTraining: Bool
    let onDelete: () -> Void
    let onEdit: () -> Void
    let onSelect: () -> Void
    
    @State private var isMenuEditing: Bool = false
    
    var body: some View {
        if isEditMode {
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill").foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
        Text(menu.name)
        Spacer()
        if(isEditMode){
            Button(action: {
                print("Edit button pressed")
                isMenuEditing.toggle()
            }, label: {
                Text("編集")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            })
            .buttonStyle(.borderless)
            .sheet(isPresented: $isMenuEditing) {
                EditTrainingMenuView(menu: menu, onSave: {
                    // onSave クロージャー内で保存処理を実行
                    onEdit()
                })
            }
        } else {
            durationView
            if isTodaySession {
                Button(action: { onSelect() }, label: {
                    Text(isCurrentTraining ? "実施中" : "開始")
                        .bold()
                        .foregroundStyle(colorScheme == .dark || isCurrentTraining ? .white : .black)
                        .padding(8)
                        .background(isCurrentTraining ? .blue : .clear)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8) // Create a rounded rectangle border
                                .stroke(isCurrentTraining ? Color.blue : Color.gray, lineWidth: 1)
                        )
                }).buttonStyle(.borderless)
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
    TrainingMenuRowHeader(menu: TrainingMenu(name: "Name", goal: "Goal", duration: TimeInterval(100), focusPoints: ["FP"], menuDescription: "Description", orderIndex: 1), isEditMode: false, isTodaySession: true, isCurrentTraining: true, onDelete: {print("Save")}, onEdit: {print("Delete")}, onSelect: {print("Select")})
}

#Preview {
    TrainingMenuRowHeader(menu: TrainingMenu(name: "Name", goal: "Goal", duration: TimeInterval(100), focusPoints: ["FP"], menuDescription: "Description", orderIndex: 1), isEditMode: false, isTodaySession: false, isCurrentTraining: true, onDelete: {print("Save")}, onEdit: {print("Delete")}, onSelect: {print("Select")})
}
