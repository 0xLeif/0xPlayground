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
  
  private var cancelBag: Set<AnyCancellable> = []
  
  var futureImage: AnyPublisher<UIImage?, Error>? =
    "https://bnetcmsus-a.akamaihd.net/cms/blog_header/ki/KI5Z7EH68HEA1589910860503.jpg"
    .url?
    .urlRequest(forHTTPMethod: .GET)
    .dataTaskPublisher
    .mapError { $0 as Error }
    .map {  UIImage(data: $0.data) }
    .eraseToAnyPublisher()
  
  var buttonForImage: (UIImage) -> UIView = { image in
    Button(
      action: {
        console.log(level: .warning("😱"))
      },
      labelView: {
        Image(image)
          .contentMode(.center)
      }
    )
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    futureImage?
      // Load UI with image
      .flatMap { [weak self] image in
        // Do this task on the main thread
        Task.main { () -> UIImage? in
          self.map { s in
            image.map { s.buttonForImage($0) }?
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
      .store(in: &cancelBag)
  }
}
