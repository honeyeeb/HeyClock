//
//  ContentView.swift
//  HeyClock
//
//  Created by 韶华笑 on 3/29/23.
//

import SwiftUI

struct AnalogClock: View {
    
    @State private var currentTime = Date()
    
    var body: some View {
        
        TimelineView(.animation(minimumInterval: 1 / 20)) { timeline in
            Canvas { ctx, size in
                // get the current hand angles
                let angels = getAngles(for: timeline.date)
                // figure out our drawing space
                let rect = CGRect(origin: .zero, size: size)
                let r = min(size.width, size.height) / 2
                
                // calculate some size constants
                let border = r / 25
                let hLength = r / 2.5
                let mLength = r / 1.5
                let sLength = r * 1.1
                let sWidth = r / 25
                
                // outside
                ctx.stroke(Circle()
                    .inset(by: border / 2)
                    .path(in: rect), with: .color(.primary), lineWidth: border)
                ctx.translateBy(x: rect.midX, y: rect.midY)
                
                // hour numbers
                drawHours(in: ctx, radius: r)
                
                // minute line
                drawHand(in: ctx, radius: r, length: mLength, angle: angels.minute)
                // hour line
                drawHand(in: ctx, radius: r, length: hLength, angle: angels.hour)
                // inner circle
                let innerRing = r / 6
                let ringWidth = r / 40
                let inner = CGRect(x: -innerRing / 2, y: -innerRing / 2, width: innerRing, height: innerRing)
                ctx.stroke(Circle()
                    .path(in: inner), with: .color(.primary), lineWidth: ringWidth)
                
                // second line
                let secondLine = Capsule()
                    .offset(x: 0, y: -r / 6)
                    .rotation(angels.second, anchor: .top)
                    .path(in: CGRect(x: -sWidth / 2, y: 0, width: sWidth, height: sLength))
                ctx.fill(secondLine, with: .color(.orange))
                
                // clear circle
                let centerPiece = Circle()
                    .path(in: inner.insetBy(dx: ringWidth, dy: ringWidth))
                ctx.blendMode = .clear
                ctx.fill(centerPiece, with: .color(.white))
                
                // normal circle
                ctx.blendMode = .normal
                ctx.stroke(centerPiece, with: .color(.orange), lineWidth: ringWidth)
                
            }
        }
    }
    
    func getAngles(for date: Date) -> (hour: Angle, minute: Angle, second: Angle) {
        // get current hour, minute, second, and nanosecond
        let parts = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        let h = Double(parts.hour ?? 0)
        let m = Double(parts.minute ?? 0)
        let s = Double(parts.second ?? 0)
        let n = Double(parts.nanosecond ?? 0)
        // covert those to angles
        var hour = Angle.degrees(30 * (h + m / 60) + 180)
        var minute = Angle.degrees(6 * (m + s / 60) + 180)
        var second = Angle.degrees(6 * (s + n / 1_000_000_000) + 180)
        // fix iOS below 16.3 bugs
        if hour.radians == .pi { hour = .radians(3.14158) }
        if minute.radians == .pi { minute = .radians(3.14158) }
        if second.radians == .pi { second = .radians(3.14158) }
        
        return (hour, minute, second)
    }
    
    func drawHand(in context: GraphicsContext, radius: Double, length: Double, angle: Angle) {
        let width = radius / 30
        
        let stalk = Rectangle()
            .rotation(angle, anchor: .top)
            .path(in: CGRect(x: -width/2, y: 0, width: width, height: length))
        context.fill(stalk, with: .color(.primary))
        
        let hand = Capsule()
            .offset(x: 0, y: radius / 5)
            .rotation(angle, anchor: .top)
            .path(in: CGRect(x: -width, y: 0, width: width * 2, height: length))
        context.fill(hand, with: .color(.primary))
    }
    
    func drawHours(in context: GraphicsContext, radius: Double) {
        let textSize = radius / 4
        let textOffset = radius * 0.75
        
        for number in 1...12 {
            let text = Text(String(number)).font(.system(size: textSize)).bold()
            let point = CGPoint(x: 0, y: -textOffset)
                .applying(CGAffineTransform(rotationAngle: Double(number) * .pi / 6))
            context.draw(text, at: point)
        }
        
    }
    
}


struct ContentView: View {
    var body: some View {
        AnalogClock()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
