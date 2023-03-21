//
//  Start_Training.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/10/14.
//

import SwiftUI

struct Start_Training: View {
    let menuList:[String]
    @Binding var menuTimeList:[Int]
    @State var time:Int = 0
    var body: some View {
        VStack{
            Text("残り"+String(time)).foregroundColor(Color.orange).font(Font.title)
                    ForEach(menuTimeList.indices, id: \.self) {i in
                            HStack{
                                Text(menuList[i])
                                Button(action:{
                                    time = menuTimeList[i]*60
                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                                if time > -1 {
                                                    time -= 1
                                                }
                                            }
                                }, label:{Text(String(menuTimeList[i]))})
                            }
                    }
        }.navigationBarTitle("トレーニング中")
    }
}

//struct Start_Training_Previews: PreviewProvider {
//    static var previews: some View {
//        Start_Training()
//    }
//}
