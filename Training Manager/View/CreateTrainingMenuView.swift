//
//  CreateTrainingMenuView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/01.
//

import SwiftUI

struct CreateTrainingMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var session: TrainingSession
    @State private var trainingMenu = TrainingMenu()
    @State var trainingMenuList: [TrainingMenu]
    
    // 分と秒を選択するための State プロパティ
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    
    // 選択できる範囲のデータ
    let minutesRange = Array(0...59)
    let secondsRange = Array(0...59)
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("メニュー名", text: Binding(
                    get: { trainingMenu.name ?? "" },
                    set: { trainingMenu.name = $0 }
                ))
                
                TextField("重点1", text: Binding(
                    get: { trainingMenu.keyFocus1 ?? "" },
                    set: { trainingMenu.keyFocus1 = $0 }
                ))
                
                TextField("目標", text: Binding(
                    get: { trainingMenu.goal ?? "" },
                    set: { trainingMenu.goal = $0 }
                ))
                HStack{
                    // ドラムロール形式のPickerで分を選択
                    Picker("Duration (分)", selection: $selectedMinutes) {
                        ForEach(minutesRange, id: \.self) { minute in
                            Text("\(minute) 分").tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    // ドラムロール形式のPickerで秒を選択
                    Picker("Duration (秒)", selection: $selectedSeconds) {
                        ForEach(secondsRange, id: \.self) { second in
                            Text("\(second) 秒").tag(second)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                NavigationLink("既存のメニューから追加", destination: SelectExistingMenu(trainingMenu: trainingMenu, trainingMenuList: trainingMenuList))
            }
            .navigationTitle("メニューの追加")
            .onAppear {
                // trainingMenu.duration を分と秒に分割して初期値を設定
                if let duration = trainingMenu.duration {
                    selectedMinutes = Int(duration) / 60
                    selectedSeconds = Int(duration) % 60
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("追加") {
                        // 分と秒を TimeInterval に変換
                        trainingMenu.duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
                        // 新しいメニューを追加してセッションに保存
                        session.menus.append(trainingMenu)
                        modelContext.insert(trainingMenu)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateTrainingMenuView(session: TrainingSession(), trainingMenuList: [])
}
