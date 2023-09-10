import SwiftUI
import MetalKit

struct MetalView: View {
  let options: Options
  @State private var gameController: GameController?
  @State private var metalView = MTKView()
  @State private var previousTranslation = CGSize.zero
  @State private var previousScroll: CGFloat = 1
    var body: some View {
      VStack {
        MetalViewRepresentable(gameController: gameController, metalView: $metalView, options: options)
          .onAppear {
            gameController = GameController(options: options)
          }
          .gesture(DragGesture(minimumDistance: 0)
            .onChanged {
              value in
              InputController.shared.touchLocation = value.location
              InputController.shared.touchDelta = CGSize(width: value.translation.width - previousTranslation.width,
                                                         height: value.translation.height - previousTranslation.height)
              previousTranslation = value.translation
              print("touched")
              // if user drags, cancel the tap touch
              if abs(value.translation.width) > 1 ||
                  abs(value.translation.height) > 1 {
                print("draging")
                InputController.shared.touchLocation = nil
              }
            }
            .onEnded { _ in
              print("end touching/dragging")
              previousTranslation = .zero
            })
          .gesture(MagnificationGesture()
            .onChanged {
              value in
              let scroll = value - previousScroll
              InputController.shared.mouseScroll.x = Float(scroll) * Settings.touchZoomSensitivity
              previousScroll = value
              print("zooming")
            }
            .onEnded { _ in
              previousScroll = 1
              print("end zooming")
            })
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
