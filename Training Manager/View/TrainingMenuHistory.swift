//
//  TrainingMenuHistory.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TrainingMenuHistory: View {
    @State var trainingMenuList: [TrainingMenu]
    @State var trainingSessionList: [TrainingSession]
    @State private var isAddingToSession: Bool = false
    @State private var currentMenu: TrainingMenu?
    
    var body: some View {
        VStack{
            Text("メニュー履歴").font(.title)
            List(trainingMenuList){menu in
                VStack(alignment: .leading) {
                    HStack(alignment: .center){
                        Text(menu.name ?? "").font(.title2)
                        Text(formatDuration(duration: menu.duration ?? 0)).bold()
                    }
                    Text(menu.goal ?? "").font(.headline)
                    Section(header: Text("フォーカスポイント")){
                        ForEach(menu.focusPoints, id: \.self){point in
                            Text(point)
                        }
                    }
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
    TrainingMenuHistory(trainingMenuList: [TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, focusPoints: ["ポイント1-1", "ポイント1-2", "ポイント1-3"], menuDescription: "備考1", orderIndex: 1),TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, focusPoints: ["ポイント2-1", "ポイント2-2", "ポイント2-3"], menuDescription: "備考2", orderIndex: 2)], trainingSessionList: [TrainingSession(theme: "テーマ", sessionDescription: "備考",sessionDate: Date())])
}
