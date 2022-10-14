//
//  ContentView.swift
//  Training Manager Watch App
//
//  Created by 井坂航 on 2022/09/27.
//

import SwiftUI

struct ContentView: View {
    @State var str = "string"
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: Create_New_Training().navigationTitle("新規")) {
                    Image(systemName:"square.and.pencil")
                    Text("新規トレーニング")
                }
                NavigationLink(destination:Load_Old_Training().navigationTitle("参照")) {
                    Image(systemName:"book")
                    Text("トレーニング履歴を参照")
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
