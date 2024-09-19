//
//  SessionDetailView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/05.
//

import SwiftUI

struct SessionDetailView: View {
    var session: TrainingSession
    
    var body: some View {
        VStack{
            Text(session.sessionDate ?? Date(), formatter: dateFormatter)
            Text(session.theme ?? "")
            Text(session.sessionDescription ?? "")
            List{
                ForEach(session.menus){menu in
                    Section(header: Text("メニュー:")) {
                        Text(menu.name ?? "").font(.title)
                    }
                    
                    Section(header: Text("練習のゴール:")) {
                        Text(menu.goal ?? "")
                    }
                    
                    Section(header: Text("フォーカスポイント:")) {
                        ForEach(menu.focusPoints, id:\.self){point in
                            Text(point)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SessionDetailView(session: TrainingSession(theme: "テーマ", sessionDescription: "備考",sessionDate: Date(), menus:[TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, focusPoints: ["ポイント1-1", "ポイント1-2", "ポイント1-3"], menuDescription: "備考1", orderIndex: 0),TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, focusPoints: ["ポイント2-1", "ポイント2-2", "ポイント2-3"], menuDescription: "備考2", orderIndex: 1)]))
}
