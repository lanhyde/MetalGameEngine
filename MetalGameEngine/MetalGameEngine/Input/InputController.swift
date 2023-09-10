import GameController

class InputController {
  struct Point {
    var x: Float
    var y: Float
    
    static let zero = Point(x: 0, y: 0)
  }
  
  static let shared = InputController()
  var keyPressed: Set<GCKeyCode> = []
  var leftMouseDown = false
  var mouseDelta = Point.zero
  var mouseScroll = Point.zero
  var touchLocation: CGPoint?
  var touchDelta: CGSize? {
    didSet {
      touchDelta?.height *= -1
      if let delta = touchDelta {
        mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
      }
      leftMouseDown = touchDelta != nil
    }
  }
  
  private init() {
    let center = NotificationCenter.default
    center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: nil) {
      notification in
      let mouse = notification.object as? GCMouse
      mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
        self.leftMouseDown = pressed
      }
      mouse?.mouseInput?.scroll.valueChangedHandler = { _, x, y in
        self.mouseScroll.x = x
        self.mouseScroll.y = y
      }
    }
    
    #if os(macOS)
    NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil }
    #endif
  }
}

