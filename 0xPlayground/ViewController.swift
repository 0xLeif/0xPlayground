//
//  ViewController.swift
//  0xPlayground
//
//  Created by Leif on 5/20/21.
//

import UIKit
import Combine
import Chronicle
import Task
import SURL
import SwiftUIKit

// Console debug logging
let console: Chronicle = Chronicle(label: "0x.playground")

class ViewController: UIViewController {
  private let startTime: Date = Date()
  
  lazy var imageTask: AnyCancellable? = "https://bnetcmsus-a.akamaihd.net/cms/blog_header/ki/KI5Z7EH68HEA1589910860503.jpg"
    .url?
    .urlRequest(forHTTPMethod: .GET)
    .dataTaskPublisher
    .mapError { $0 as Error }
    .map {  UIImage(data: $0.data) }
    .eraseToAnyPublisher()
    // Update the UI with the image
    .flatMap { [weak self] image in
      // Do this task on the main thread
      Task.main { () -> UIImage? in
        self.map { s in
          image.map(\.buttonForImage)?
            .func { button in
              s.view.embed {
                ScrollView {
                  button
                }
              }
            }
        }
        .func { _ in
          image
        }
      }
    }
    // Deal with image. Caching, Logging, Etc.
    .sink(
      .success { image in
        console.log(
          level: image == nil
            ? .error("Image is nil!", nil)
            : .success("Image loaded!")
        )
        
        console.log(level: .info("\(#fileID) startTime.timeIntervalSinceNow ~= \(String(format: "%f", abs(self.startTime.timeIntervalSinceNow)))"))
      }
    )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageTask
      .map { _ in console.log(level: .info("Starting imageTask!")) }
      .toVoid
  }
}

func to<T>(void: T) { }

extension Optional {
  var toVoid: Void {
    to(void: self)
  }
}

extension UIImage {
  var buttonForImage: UIView {
    Button(
      action: {
        console.log(level: .warning("😱"))
      },
      labelView: {
        Image(self)
          .contentMode(.center)
      }
    )
  }
}
