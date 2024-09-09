//
//  SelectExistingMenu.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/09.
//

import SwiftUI

struct SelectExistingMenu: View {
    var trainingMenuList: [TrainingMenu]
    var body: some View{
        VStack{
            Text("メニュー履歴").font(.title)
            List(trainingMenuList){menu in
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
    SelectExistingMenu(trainingMenuList: [TrainingMenu(name: "3v2", goal: "Goal", duration: TimeInterval(600), keyFocus1: "kf1", keyFocus2: "kf2", keyFocus3: "kf3", menuDescription: "頑張る")])
}
