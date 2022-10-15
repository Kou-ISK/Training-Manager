//
//  ContentView.swift
//  Training Manager
//
//  Created by 井坂航 on 2022/09/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
                List{
                    HStack{
                        Image(systemName:"square.and.pencil")
                        NavigationLink(destination: Create_New_Training()) {
                                    Text("新規トレーニング")
                                }
                    }
                    HStack{
                        Image(systemName:"book")
                        NavigationLink(destination: Load_Old_Training()) {
                                    Text("トレーニング履歴を参照")
                                }
                    }
            }
            .navigationTitle("メインメニュー")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
