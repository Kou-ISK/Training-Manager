//
//  Start_Training.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/10/14.
//

import SwiftUI

struct Start_Training: View {
    let menuList:[String]
    let menuTimeList:[String]
    var body: some View {
        VStack{
            //        ForEach(menuList.indices, id: \.self) {i in
            //            HStack{
            //                Text(menuList[i])
            //                Text(menuTimeList[i])
            //            }
            //        }
            Text(menuList[0])
            Text(menuTimeList[0])
        }.navigationBarTitle("トレーニング中")
    }
}

//struct Start_Training_Previews: PreviewProvider {
//    static var previews: some View {
//        Start_Training()
//    }
//}
