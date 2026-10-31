// Lifts the subject out of a photo (same as macOS "Lift subject from background").
// usage: swift tools/cutout.swift <in.jpg> <out.png>
import Foundation
import Vision
import CoreImage
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: cutout.swift <in> <out.png>"); exit(1) }
let input = URL(fileURLWithPath: args[1]), output = URL(fileURLWithPath: args[2])

let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(url: input)
try handler.perform([request])
guard let result = request.results?.first else { print("no subject found"); exit(2) }

let masked = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler, croppedToInstancesExtent: true)
let ci = CIImage(cvPixelBuffer: masked)
let cg = CIContext().createCGImage(ci, from: ci.extent)!
let dest = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, cg, nil)
CGImageDestinationFinalize(dest)
print("\(args[2]) \(cg.width)x\(cg.height), \(result.allInstances.count) subject(s)")
