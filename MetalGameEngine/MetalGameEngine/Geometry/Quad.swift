import MetalKit

struct Quad {
  let vertices: [float3] = [
    [-1, 0,  1],
    [ 1, 0, -1],
    [-1, 0, -1],
    [-1, 0,  1],
    [ 1, 0, -1],
    [ 1, 0,  1]
  ]
  
  var vertexBuffer: MTLBuffer {
    Renderer.device.makeBuffer(bytes: vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])!
  }
  
  static func createControlPoints(patches: (horizontal: Int, vertical: Int), size: (width: Float, height: Float)) -> [float3] {
    var points: [float3] = []
    
    let width = 1 / Float(patches.horizontal)
    let height = 1 / Float(patches.vertical)
    
    for row in 0..<patches.vertical {
      let row = Float(row)
      for i in 0..<patches.horizontal {
        let column = Float(i)
        let left = width * column
        let bottom = height * row
        let right = width * column + width
        let top = height * row + height
        points.append([left, 0, top])
        points.append([right, 0, top])
        points.append([right, 0, bottom])
        points.append([left, 0, bottom])
      }
    }
    
    points = points.map {
      [ $0.x * size.width - size.width / 2, 0, $0.z * size.height / 2]
    }
    
    return points
  }
}
