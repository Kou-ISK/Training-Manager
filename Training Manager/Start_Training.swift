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
    var body: some View {
        VStack{
                    ForEach(menuTimeList.indices, id: \.self) {i in
                        VStack{
                            HStack{
                                Text(menuList[i])
                                Button(action:{
                                    var time = menuTimeList[i]*60
                                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                                if time > -1 {
                                                    time -= 1
                                                    print(time)
                                                }
                                            }
                                }, label:{Text(String(menuTimeList[i]))})
                            }
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
