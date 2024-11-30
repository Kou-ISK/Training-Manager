//
//  TrainingMenuHistory.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct TrainingMenuHistory: View {
    @Environment(\.modelContext) private var modelContext
    
    var trainingSessionList: [TrainingSession]
    @State private var isEditMode: Bool = false
    @State private var menuToDelete: TrainingMenu?
    @State private var isShowDeleteAlart: Bool = false
    
    private var trainingMenuList: [TrainingMenu]{
        return trainingSessionList.flatMap({$0.menus})
    }
    
    // 検索用のテキスト
    @State private var searchText: String = ""
    // 検索結果
    private var filteredMenu: [TrainingMenu] {
        let searchResult = trainingMenuList.filter { $0.name.localizedStandardContains(searchText) }
        
        return searchText.isEmpty ? trainingMenuList : searchResult
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                List(filteredMenu.sorted(by: { $0.orderIndex < $1.orderIndex })){ menu in
                    // TODO: TodaySessionViewかSessionDetailViewのメニューリストと共通化出来るか検討
                    // メニュー名の表示
                    DisclosureGroup(content: {
                        // メニュー詳細を階層的に表示
                        VStack(alignment: .leading, spacing: 8) {
                            // 練習のゴール
                            if !menu.goal.isEmpty {
                                Text("練習のゴール:")
                                    .font(.headline)
                                Text(menu.goal)
                                    .font(.body)
                                    .padding(.bottom, 4)
                            }
                            
                            // フォーカスポイント
                            if !menu.focusPoints.isEmpty {
                                Text("フォーカスポイント:")
                                    .font(.headline)
                                ForEach(menu.focusPoints, id: \.self) { point in
                                    Text(point.label)
                                        .font(.body)
                                }
                                .padding(.bottom, 4)
                            }
                            
                            // 備考
                            if let description = menu.menuDescription, !description.isEmpty {
                                Text("備考:")
                                    .font(.headline)
                                Text(description)
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 8)
                    }){
                        if isEditMode {
                            HStack{
                                Button(action: {
                                    isShowDeleteAlart.toggle()
                                }, label:{
                                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                                }).buttonStyle(.borderless).background(.clear)
                                    .alert("メニューの削除", isPresented: $isShowDeleteAlart, actions: {
                                        Button("削除", role: .destructive) {
                                            print(menu)
                                            deleteMenu(menu: menu)
                                        }
                                        Button("キャンセル", role: .cancel) {}
                                    })
                            }
                        }
                        Text(menu.name)
                        Spacer()
                        HStack{
                            Image(systemName: "stopwatch")
                            Text(formatDuration(duration: menu.duration ?? 0))
                        }.foregroundStyle(.white).fontWeight(.bold).padding(5).background(.green).cornerRadius(30)
                    }
                }.searchable(text: $searchText)
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
    TrainingMenuHistory(trainingSessionList: [TrainingSession(theme: "Theme", sessionDescription: "Session", sessionDate: Date(), menus: [TrainingMenu(name: "Menu", goal: "Goal", duration: TimeInterval(100), focusPoints: ["FP1"], menuDescription: "Description", orderIndex: 1)])])
}
