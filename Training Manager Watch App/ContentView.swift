//
//  ContentView.swift
//  Training Manager Watch App
//
//  Created by 井坂航 on 2022/09/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "bell.fill")
                Text("Main Menu")
            }
            List {
                Button("Set new training"){
//                    Controllerにクラスに移動？
//                    Viewを変更するには？
                }
                Button("Load from iPhone"){
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
