//
//  TrainingMenuHistory.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TrainingMenuHistory: View {
    @ObservedObject var contentViewModel: ContentViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditMode: Bool = false
    @State private var menuToDelete: TrainingMenu?
    @State private var isShowDeleteAlart: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack{
                List(contentViewModel.trainingMenuList.sorted(by: { $0.orderIndex < $1.orderIndex })){ menu in
                    HStack{
                        if isEditMode {
                            HStack{
                                Button(action: {
                                    menuToDelete = menu // 削除対象のメニューを設定
                                    isShowDeleteAlart.toggle()
                                }, label:{
                                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                }).buttonStyle(.borderless).background(.clear)
                                    .alert("メニューの削除", isPresented: $isShowDeleteAlart, actions: {
                                        Button("削除", role: .destructive) {
                                            print(menu)
                                            if let menuToDelete = menuToDelete {
                                                deleteMenu(menu: menuToDelete) // 削除対象のメニューを削除
                                            }
                                        }
                                        Button("キャンセル", role: .cancel) {}
                                    })
                            }
                        }
                        VStack(alignment: .leading) {
                            HStack(alignment: .center){
                                Text(menu.name).font(.headline)
                                HStack{
                                    Image(systemName: "stopwatch")
                                    Text(formatDuration(duration: menu.duration ?? 0))
                                }.foregroundStyle(.white).fontWeight(.bold).padding(5).background(.green).cornerRadius(30)
                            }
                            Text(menu.goal).font(.subheadline).underline()
                            ForEach(menu.focusPoints, id: \.self){ point in
                                Text(point).font(.caption)
                            }
                            if(menu.menuDescription != "" || menu.menuDescription != nil){
                                Text(menu.menuDescription ?? "").font(.caption).foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditMode.toggle()
                    } label: {
                        Text(isEditMode ? "完了" : "編集")
                    }
                }
            }
        }
    }
    
    // 時間をmm:ss形式で表示
    private func formatDuration(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // メニューを削除する処理
    private func deleteMenu(menu: TrainingMenu) {
        contentViewModel.trainingMenuList.removeAll(where: {$0.id == menu.id})
        // データベースから削除
        modelContext.delete(menu)
        // データベースに保存
        do {
            try modelContext.save() // 変更を保存
        } catch {
            print("Failed to save context: \(error)")
        }
        self.isEditMode = false
    }
}

#Preview {
    TrainingMenuHistory(contentViewModel: ContentViewModel(
        trainingSessionList: [],
        trainingMenuList: [TrainingMenu(name: "メニュー1", goal: "ゴール1", duration: 300, focusPoints: ["ポイント1-1", "ポイント1-2", "ポイント1-3"], menuDescription: "備考1", orderIndex: 1),TrainingMenu(name: "メニュー2", goal: "ゴール2", duration: 300, focusPoints: ["ポイント2-1", "ポイント2-2", "ポイント2-3"], menuDescription: "備考2", orderIndex: 2)]))
}
