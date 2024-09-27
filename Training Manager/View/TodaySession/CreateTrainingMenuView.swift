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
    
    @State private var newFocusPoint: String = ""
    
    // 分と秒を選択するための State プロパティ
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    
    // 選択できる範囲のデータ
    let minutesRange = Array(0...59)
    let secondsRange = Array(0...59)
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("メニュー名")){
                    TextField("メニュー名", text: Binding(
                        get: { trainingMenu.name },
                        set: { trainingMenu.name = $0 }
                    ))
                }
                
                Section(header: Text("フォーカスポイント")) {
                    ForEach(trainingMenu.focusPoints, id: \.self) { point in
                        HStack {
                            Text(point)
                            Spacer()
                            Button(action: {
                                removeFocusPoint(point)
                            }) {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                            }.buttonStyle(.borderless)
                        }
                    }
                    
                    HStack {
                        TextField("新しいフォーカスポイント", text: $newFocusPoint)
                        Button(action: {
                            addFocusPoint()
                        }) {
                            Image(systemName: "plus.circle.fill").foregroundColor(.green)
                        }
                    }
                }
                Section(header: Text("練習のゴール")){
                    TextField("ゴール", text: Binding(
                        get: { trainingMenu.goal },
                        set: { trainingMenu.goal = $0 }
                    ))
                }
                
                Section(header: Text("備考")){
                    TextField("備考", text: Binding(
                        get: { trainingMenu.menuDescription ?? "" },
                        set: { trainingMenu.menuDescription = $0 }
                    ))
                }
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
                        saveAndDismiss()
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
    
    private func addFocusPoint() {
        if !newFocusPoint.isEmpty {
            trainingMenu.focusPoints.append(newFocusPoint)  // 直接TrainingMenuに追加
            newFocusPoint = "" // 追加後にテキストフィールドをクリア
        }
    }
    
    private func removeFocusPoint(_ point: String) {
        trainingMenu.focusPoints.removeAll { $0 == point }
    }
    
    private func saveAndDismiss() {
        // 最後のフォーカスポイントの追加がまだなら追加
        if !newFocusPoint.isEmpty {
            addFocusPoint()
        }
        
        // 分と秒を TimeInterval に変換して保存
        trainingMenu.duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
        trainingMenu.orderIndex = trainingMenuList.count
        
        // 新しいメニューをセッションに追加
        session.menus.append(trainingMenu)  // TrainingSessionにメニューを追加
        
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
        
        // ビューを閉じる
        dismiss()
    }
    
}

#Preview {
    CreateTrainingMenuView(session: TrainingSession(), trainingMenuList: [])
}
