import Foundation

class GameController: NSObject {
  var options = Options()
  
  init(options: Options) {
    super.init()
    self.options = options
  }
}
