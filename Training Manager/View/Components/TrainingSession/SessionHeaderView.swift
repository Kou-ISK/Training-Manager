//
//  SessionHeaderView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/12/27.
//

import SwiftUI

struct SessionHeaderView: View {
    let session: TrainingSession
    let isEditMode: Bool
    let onDelete: () -> Void

    @State private var isShowDeleteSessionAlert: Bool = false

    var body: some View {
        HStack {
            if isEditMode {
                Button(action: {
                    isShowDeleteSessionAlert.toggle()
                }, label: {
                    Image(systemName: "minus.circle.fill").foregroundStyle(.red)
                })
                .buttonStyle(.borderless)
                .background(.clear)
                .alert("セッションの削除", isPresented: $isShowDeleteSessionAlert, actions: {
                    Button("削除", role: .destructive) {
                        onDelete()
                    }
                    Button("キャンセル", role: .cancel) {}
                })
            }

            VStack(alignment: .leading) {
                Text(session.sessionDate ?? Date(), formatter: dateFormatter)
                Text("テーマ: \(session.theme ?? "")").font(.subheadline)
                Text("備考: \(session.sessionDescription ?? "")")
            }
            .padding(8)
        }
        .padding(.horizontal, 8)
    }
}

//#Preview {
//    SessionHeaderView()
//}
