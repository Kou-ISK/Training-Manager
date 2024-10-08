//
//  TrainingMenuDetailView.swift
//  Watch Training Manager Watch App
//
//  Created by 井坂航 on 2024/09/25.
//

import SwiftUI

struct TrainingMenuDetailView: View {
    var menu: TrainingMenu
    
    func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {

            VStack{
                Text(menu.name)
                Text(menu.goal)
                ForEach(menu.focusPoints, id:\.self){point in
                    Text("・\(point)")
                }
            }
    }
}

#Preview {
    TrainingMenuDetailView(menu: TrainingMenu(name: "メニュー", goal: "ゴール", duration: TimeInterval(600), focusPoints: ["FP1", "FP2"], menuDescription: "備考", orderIndex: 0))
}
