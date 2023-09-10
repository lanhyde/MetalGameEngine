//
//  ContentView.swift
//  MetalGameEngine
//
//  Created by lanhaide on 2023/09/10.
//

import SwiftUI

struct ContentView: View {
  @StateObject var options = Options()
  @State var checked: Int = 1
    var body: some View {
      MetalView(options: options)
        .border(Color.black, width: 2)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
