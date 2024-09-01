//  CreateTrainingSessionView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI
import SwiftData

struct CreateTrainingSessionView: View {
    @State var trainingSessionList: [TrainingSession]
    @State private var trainingMenuList: [TrainingMenu] = []
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Button(action: {
                trainingMenuList.append(TrainingMenu())
            }, label: {
                VStack {
                    Text("追加")
                    Image(systemName: "plus").frame(height: 30.0)
                }
            })
            
            ForEach(trainingMenuList.indices, id: \.self) { index in
                TextField("メニュー名", text: Binding(
                    get: { trainingMenuList[index].name ?? "" },
                    set: { trainingMenuList[index].name = $0 }
                ))
                
                TextField("重点1", text: Binding(
                    get: { trainingMenuList[index].keyFocus1 ?? "" },
                    set: { trainingMenuList[index].keyFocus1 = $0 }
                ))
                
                TextField("目標", text: Binding(
                    get: { trainingMenuList[index].goal ?? "" },
                    set: { trainingMenuList[index].goal = $0 }
                ))
                
                Button(action:{
                    modelContext.insert(trainingMenuList[index])
                },label: {Text("追加")})
            }
        }
    }
}

struct CreateNewTrainingSessionPreviews: PreviewProvider {
    static var previews: some View {
        // プレビュー用にデフォルトの引数を渡す
        CreateTrainingSessionView(trainingSessionList: [])
    }
}
