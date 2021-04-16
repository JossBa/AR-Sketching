//
//  MessageLabel.swift
//  AR-Sketch
//
// Created by Josephine Battiston on 26.05.20.
//
//
// basic method taken from sample project with url:
// https://developer.apple.com/documentation/arkit/creating_a_multiuser_ar_experience
//
// Copyright © 2020 Apple Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import UIKit

/// - Tag: MessageLabel
@IBDesignable
class MessageLabel: UILabel {
    
    var ignoreMessages = false
        
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
    
    func displayMessage(_ text: String, duration: TimeInterval = 10.0) {
        guard !ignoreMessages else { return }
        guard !text.isEmpty else {
            DispatchQueue.main.async {
                self.isHidden = true
                self.text = ""
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isHidden = false
            self.text = text
            
            let tag = self.tag + 1
            self.tag = tag
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {

                if self.tag == tag {
                    self.isHidden = true
                }
            }
        }
    }
}
