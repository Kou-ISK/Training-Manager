//
//  CircleProgressBarView.swift
//  Training Manager
//
//  Created by 井坂航 on 2024/09/04.
//

import SwiftUI

struct CircleProgressBarView: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack{
            Circle().stroke(lineWidth: 20).opacity(0.3).foregroundStyle(.blue)
            
            Circle().trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)).foregroundStyle(.blue)
                .rotationEffect(Angle(degrees: 270.0))
        }}
}

#Preview {
     @State var progress: CGFloat = 0.5
     return CircleProgressBarView(progress: $progress)
}