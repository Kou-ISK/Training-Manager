//
//  EditTrainingMenuView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/14.
//

import SwiftUI

struct EditTrainingMenuView: View {
    @Environment(\.dismiss) private var dismiss // 画面を閉じるための環境値
    
    @State var menu: TrainingMenu
    var onSave: () -> Void // 保存アクションを実行するクロージャー
    
    // 分と秒を選択するための State プロパティ
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    
    // 選択できる範囲のデータ
    let minutesRange = Array(0...59)
    let secondsRange = Array(0...59)
    
    @State private var newFocusPoint: String = ""
    
    @State private var name: String = ""
    @State private var goal: String = ""
    
    @State private var focusPoints: [String] = []
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button("保存") {
                addFocusPoint()
                menu.name = name
                menu.goal = goal
                menu.focusPoints = focusPoints
                menu.duration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
                onSave() // 保存アクションを実行
                dismiss() // 画面を閉じる
            }
            Form {
                Section(header: Text("メニュー名")){
                    TextField("メニュー名", text: $name)
                        .padding()
                }
                
                Section(header: Text("練習のゴール")){
                    TextField("目標", text: $goal)
                        .padding()
                }
                
                Section(header: Text("フォーカスポイント")) {
                    ForEach(focusPoints, id: \.self) { point in
                        HStack {
                            Text(point)
                            Spacer()
                            Button(action: {
                                removeFocusPoint(point)
                            }) {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                            }
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
                Section(header: Text("練習時間")){
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
                }
            }
            .onAppear {
                // 編集中のメニューの情報をセット
                name = menu.name ?? ""
                goal = menu.goal ?? ""
                focusPoints = menu.focusPoints
                
                // trainingMenu.duration を分と秒に分割して初期値を設定
                if let duration = menu.duration {
                    selectedMinutes = Int(duration) / 60
                    selectedSeconds = Int(duration) % 60
                }
            }
        }
        .padding()
    }
    
    private func addFocusPoint() {
        if !newFocusPoint.isEmpty {
            focusPoints.append(newFocusPoint)  // 直接TrainingMenuに追加
            newFocusPoint = "" // 追加後にテキストフィールドをクリア
        }
    }
    
    private func removeFocusPoint(_ point: String) {
        focusPoints.removeAll { $0 == point }
    }
}

#Preview {
    EditTrainingMenuView(menu: TrainingMenu(), onSave: {
        // onSave クロージャー内で保存処理を実行
        // ここで何かアクションを実行するか、何も処理しないかを決めることができます
        print("Menu has been saved")
    })
}
