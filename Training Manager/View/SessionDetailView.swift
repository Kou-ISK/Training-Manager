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
                        Text(menu.keyFocus1 ?? "")
                        Text(menu.keyFocus2 ?? "")
                        Text(menu.keyFocus3 ?? "")
                    }
                }
            }
        }
    }
}

#Preview {
    SessionDetailView(session: TrainingSession(theme: "テーマ", sessionDescription: "備考",sessionDate: Date(), menus:[TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, keyFocus1: "ポイント1-1", keyFocus2: "ポイント1-2", keyFocus3: "ポイント1-3", menuDescription: "備考1"),TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, keyFocus1: "ポイント2-1", keyFocus2: "ポイント2-2", keyFocus3: "ポイント2-3", menuDescription: "備考2")]))
}
