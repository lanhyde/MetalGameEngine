//
//  MetalView.swift
//  MetalGameEngine
//
//  Created by lanhaide on 2023/09/10.
//

import SwiftUI
import MetalKit

struct MetalView: View {
  let options: Options
  @State private var gameController: GameController?
  @State private var metalView = MTKView()
  
    var body: some View {
      VStack {
        MetalViewRepresentable(gameController: gameController, metalView: $metalView, options: options)
          .onAppear {
            gameController = GameController(options: options)
          }
          .gesture(DragGesture(minimumDistance: 0)
            .onChanged {
              value in
              
            }
          )
      }
    }
}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        MetalView(options: Options())
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
  let gameController: GameController?
  @Binding var metalView: MTKView
  let options: Options
  
  #if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
  #elseif os(iOS)
  func makeNSView(context: Context) -> MTKView {
    metalView
  }
  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
  #endif
  
  func updateMetalView() {
    gameController?.options = options
  }
}

struct MetalView_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView(options: Options())
    }
  }
}
