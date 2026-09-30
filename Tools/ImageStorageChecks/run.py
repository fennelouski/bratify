#!/usr/bin/env python3
"""Compile actual storage methods with image-codec stubs; never touch app directories."""
import pathlib, subprocess, tempfile
repo=pathlib.Path(__file__).resolve().parents[2]
source=(repo/'brat/ImageService.swift').read_text()
save=source[source.index('    @discardableResult\n    func saveImageToDisk'):source.index('    func loadImageFromDisk')]
migrate=source[source.index('    static func migrateLegacyImages'):source.index('    private func getFilePath')]
assert 'performDiskCacheManagement' not in source and 'reduceDiskCache' not in source and 'manageDiskCache' not in source
prefix='''import Foundation
final class UIImage: NSObject {
 let data: Data?
 init(_ data: Data?) { self.data = data }
 func jpegData(compressionQuality: CGFloat) -> Data? { data }
 func pngData() -> Data? { data }
}
extension String { var key: String { self } }
class ImageService {
 static var sharedICloudImagesDirectory: URL?
 let memoryCache = NSCache<NSString, UIImage>()
 let directory: URL
 init(_ directory: URL) { self.directory = directory }
 func getFilePath(forImageName name: String) -> URL { directory.appendingPathComponent(name) }
'''
checks='''}
@main struct Checks {
 @MainActor static func main() throws {
  let fm=FileManager.default
  let root=fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  try fm.createDirectory(at:root,withIntermediateDirectories:true)
  defer {try? fm.removeItem(at:root)}
  let images=root.appendingPathComponent("images");try fm.createDirectory(at:images,withIntermediateDirectories:true)
  let cloud=root.appendingPathComponent("cloud");try fm.createDirectory(at:cloud,withIntermediateDirectories:true)
  ImageService.sharedICloudImagesDirectory=cloud
  let service=ImageService(images);let bytes=Data("test image bytes".utf8);let image=UIImage(bytes)
  assert(service.saveImageToDisk(image,addToInMemoryCache:true,withName:"saved",compressionQuality:0.7))
  assert(try Data(contentsOf:images.appendingPathComponent("saved")) == bytes)
  assert(try Data(contentsOf:cloud.appendingPathComponent("saved")) == bytes)
  assert(service.memoryCache.object(forKey:"saved") === image)
  assert(!service.saveImageToDisk(UIImage(nil),addToInMemoryCache:true,withName:"invalid",compressionQuality:0.7))
  assert(service.memoryCache.object(forKey:"invalid") == nil)
  let blocked=root.appendingPathComponent("blocked");try bytes.write(to:blocked)
  let failing=ImageService(blocked)
  assert(!failing.saveImageToDisk(image,addToInMemoryCache:true,withName:"failed",compressionQuality:0.7))
  assert(failing.memoryCache.object(forKey:"failed") == nil)
  assert(!fm.fileExists(atPath:cloud.appendingPathComponent("failed").path))
  let legacy=root.appendingPathComponent("legacy");try fm.createDirectory(at:legacy,withIntermediateDirectories:true)
  try bytes.write(to:legacy.appendingPathComponent("new"));try bytes.write(to:legacy.appendingPathComponent("conflict"))
  let existing=Data("newer destination".utf8);try existing.write(to:images.appendingPathComponent("conflict"))
  ImageService.migrateLegacyImages(from:legacy,to:images)
  assert(try Data(contentsOf:images.appendingPathComponent("new")) == bytes)
  assert(!fm.fileExists(atPath:legacy.appendingPathComponent("new").path))
  assert(try Data(contentsOf:legacy.appendingPathComponent("conflict")) == bytes)
  assert(try Data(contentsOf:images.appendingPathComponent("conflict")) == existing)
  ImageService.migrateLegacyImages(from:legacy,to:blocked)
  assert(try Data(contentsOf:legacy.appendingPathComponent("conflict")) == bytes)
  print("PASS: durable save/cache/cloud ordering; encode and filesystem failures; migration success, conflicts and failed copies; no disk eviction")
 }
}
'''
# Swift assert's nonthrowing autoclosure needs reads evaluated first.
checks=checks.replace('assert(try Data(contentsOf:', 'assert((try! Data(contentsOf:').replace(')) == bytes)', '))) == bytes)').replace(')) == existing)', '))) == existing)')
with tempfile.TemporaryDirectory(prefix='bratify-image-check-') as folder:
 folder=pathlib.Path(folder);program=folder/'checks.swift';program.write_text(prefix+save+migrate+checks)
 subprocess.run(['swiftc','-parse-as-library',str(program),'-o',str(folder/'checks')],check=True)
 subprocess.run([str(folder/'checks')],check=True)
