//  Create_New_Training.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct Create_New_Training: View {
    @State var menuList:[String] = [""]
    @State var menuTimeList:[String]=[""]
    @State var count : Int = 0
    var body: some View {
        HStack(spacing:60){
            Button(action: {
                count = count+1
                menuList.append("")
                menuTimeList.append("")
            }, label: {
                VStack{Text("追加")
                    Image(systemName: "plus").frame(height: 30.0)
                }
            })
            Button(action: {
                menuList.removeLast()
                menuTimeList.removeLast()
            }, label: {
                VStack{Text("削除")
                    Image(systemName: "minus").frame(height: 30.0)
                }
            }).foregroundColor(.red)
            
        }
        
        ForEach(menuList.indices, id: \.self) {i in
            HStack{
                TextField("新規メニュー", text: $menuList[i])
                TextField("時間(mm:ss)", text: $menuTimeList[i]).keyboardType(.numberPad)
            }
        }
    }
}

struct Create_New_Training_Previews: PreviewProvider {
    static var previews: some View {
        Create_New_Training()
    }
}
