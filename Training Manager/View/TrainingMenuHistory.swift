//
//  TrainingMenuHistory.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TrainingMenuHistory: View {
    @State var trainingMenuList: [TrainingMenu]
    var body: some View {
        Text("メニュー履歴").font(.title)
        List(trainingMenuList){menu in
            VStack(alignment: .leading) {
                HStack{
                    Text(menu.name ?? "").font(.title2)
                    Spacer()
                    Text(formatDuration(duration: menu.duration ?? 0)).bold()
                }
                Text(menu.goal ?? "").font(.headline)
                Text(menu.keyFocus1 ?? "")
                Text(menu.keyFocus2 ?? "")
                Text(menu.keyFocus3 ?? "")
                
                
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
    TrainingMenuHistory(trainingMenuList: [TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, keyFocus1: "ポイント1-1", keyFocus2: "ポイント1-2", keyFocus3: "ポイント1-3", menuDescription: "備考1"),TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, keyFocus1: "ポイント2-1", keyFocus2: "ポイント2-2", keyFocus3: "ポイント2-3", menuDescription: "備考2")])
}
