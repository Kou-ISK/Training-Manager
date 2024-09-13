//
//  SelectExistingMenuView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/09.
//

import SwiftUI

struct SelectExistingMenu: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var trainingMenu: TrainingMenu
    var trainingMenuList: [TrainingMenu]
    var body: some View{
        VStack(alignment: .center){
            Text("メニュー履歴").font(.title)
            List(trainingMenuList){menu in
                HStack{
                    VStack(alignment: .leading) {
                        HStack(alignment: .center){
                            Text(menu.name ?? "").font(.title2)
                            Text(formatDuration(duration: menu.duration ?? 0)).bold()
                        }
                        Text(menu.goal ?? "").font(.headline)
                        Text(menu.keyFocus1 ?? "")
                        Text(menu.keyFocus2 ?? "")
                        Text(menu.keyFocus3 ?? "")
                    }
                    Spacer()
                    Button("追加") {
                        trainingMenu.name = menu.name
                        trainingMenu.duration = menu.duration
                        trainingMenu.goal = menu.goal
                        trainingMenu.keyFocus1 = menu.keyFocus1
                        trainingMenu.keyFocus2 = menu.keyFocus2
                        trainingMenu.keyFocus3 = menu.keyFocus3
                        dismiss()
                    }.buttonStyle(.borderedProminent)
                }
            }
        }
    }
    // 時間をmm:ss形式で表示
    func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    SelectExistingMenu(trainingMenu: TrainingMenu(),
                       trainingMenuList: [TrainingMenu(name: "3v2", goal: "Goal", duration: TimeInterval(600), keyFocus1: "kf1", keyFocus2: "kf2", keyFocus3: "kf3", menuDescription: "頑張る", orderIndex: 0)])
}
