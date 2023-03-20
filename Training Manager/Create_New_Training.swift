//  Create_New_Training.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/30.
//

import SwiftUI

struct Create_New_Training: View {
    @State var menuList:[String] = [""]
    @State var menuTimeList:[Int] = []
    @State var count : Int = 0
    @State var show: Bool = false
    var trainingMenu: [[String]] = []
    var body: some View {
        NavigationView{
            VStack{
                NavigationLink(destination: Start_Training(menuList:menuList,menuTimeList: $menuTimeList)){
                    Text("開始")
                }
                HStack(spacing:60){
                    Button(action: {
                        count = count+1
                        menuList.append("")
                        menuTimeList.append(0)
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
                ForEach(menuTimeList.indices, id: \.self) {i in
                    HStack{
                        TextField("新規メニュー", text: $menuList[i])
                        Picker(selection: $menuTimeList[i], label: Text("")) {
                            Text("2").tag(2).font(.title2)
                                            Text("3").tag(3).font(.title2)
                                            Text("5").tag(5).font(.title2)
                                            Text("10").tag(10).font(.title2)
                                            Text("15").tag(15).font(.title2)
                                            Text("20").tag(20).font(.title2)
                        }
//                        TextField("時間(mm:ss)", text: $menuTimeList[i]).keyboardType(.numberPad)
                    }
                }
            }
        }
    }
}

struct Create_New_Training_Previews: PreviewProvider {
    static var previews: some View {
        Create_New_Training()
    }
}
