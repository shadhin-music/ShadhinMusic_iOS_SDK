//
//  UIControl++.swift
//  Shadhin
//
//  Created by Joy on 25/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit
import Combine

@available(iOS 13.0, *)
extension UIControl {
    
    class InteractionSubscription<S: Subscriber>: Combine.Subscription where S.Input == Void {
        
        // 1
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        // 2
        init(subscriber: S,
             control: UIControl,
             event: UIControl.Event) {
            
            self.subscriber = subscriber
            self.control = control
            self.event = event
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        @objc func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }
        // 3
        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() {}
    }
   
    struct InteractionPublisher: Publisher {
            
            // 2
            typealias Output = Void
            typealias Failure = Never
            
            // 3
            private let control: UIControl
            private let event: UIControl.Event
            
            init(control: UIControl, event: UIControl.Event) {
                self.control = control
                self.event = event
            }
            
            
            func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
                    
                // 1
                let subscription = InteractionSubscription(
                    subscriber: subscriber,
                    control: control,
                    event: event
                )
                    
                // 2
                subscriber.receive(subscription: subscription)
            }
        }
        func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
            
            return InteractionPublisher(control: self, event: event)
        }
}

//how to use
//        private func observeButtonTaps() {
//                button
//                    .publisher(for: .touchUpInside)
//                    .sink { _ in
//                        print("Tapped")
//                    }
//                    .store(in: &cancellables)
//
//        }
