import SwiftUI

// MARK: - Animal Mood
enum AnimalMood {
    case waiting
    case eating
    case happy
}

// MARK: - Animal Customer View (Exact Vector Drawing Matching Android Canvas)
struct AnimalCustomerView: View {
    let animalType: AnimalType
    var mood: AnimalMood = .waiting
    var size: CGFloat = 130

    @State private var bounceY: CGFloat = 0
    @State private var chewOpen: CGFloat = 0

    var body: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2

            switch animalType {
            case .panda:
                drawPanda(context: context, cx: cx, cy: cy, mood: mood, chewProgress: chewOpen)
            case .fox:
                drawFox(context: context, cx: cx, cy: cy, mood: mood, chewProgress: chewOpen)
            case .puppy:
                drawPuppy(context: context, cx: cx, cy: cy, mood: mood, chewProgress: chewOpen)
            case .kitty:
                drawKitty(context: context, cx: cx, cy: cy, mood: mood, chewProgress: chewOpen)
            case .bunny:
                drawBunny(context: context, cx: cx, cy: cy, mood: mood, chewProgress: chewOpen)
            }

            if mood == .happy {
                drawHeart(context: context, center: CGPoint(x: cx + 45, y: cy - 55), color: .pinkStrawberry, size: 14)
                drawHeart(context: context, center: CGPoint(x: cx - 45, y: cy - 50), color: Color(hex: 0xFFFF80AB), size: 10)
            }
        }
        .frame(width: size, height: size)
        .offset(y: bounceY)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bounceY = 6
            }
            if mood == .eating {
                withAnimation(.linear(duration: 0.22).repeatForever(autoreverses: true)) {
                    chewOpen = 1.0
                }
            }
        }
        .onChange(of: mood) { newMood in
            if newMood == .eating {
                withAnimation(.linear(duration: 0.22).repeatForever(autoreverses: true)) {
                    chewOpen = 1.0
                }
            } else {
                withAnimation(.linear(duration: 0.1)) {
                    chewOpen = 0
                }
            }
        }
    }

    // MARK: - Fox
    private func drawFox(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        let foxOrange = Color(hex: 0xFFFF7043)
        let foxWhite = Color(hex: 0xFFFFF8E7)
        let darkTip = Color(hex: 0xFF3E2723)

        // Ears
        var earLeft = Path()
        earLeft.move(to: CGPoint(x: cx - 56, y: cy - 14))
        earLeft.addLine(to: CGPoint(x: cx - 46, y: cy - 72))
        earLeft.addLine(to: CGPoint(x: cx - 14, y: cy - 42))
        earLeft.closeSubpath()
        context.fill(earLeft, with: .color(foxOrange))

        var earRight = Path()
        earRight.move(to: CGPoint(x: cx + 56, y: cy - 14))
        earRight.addLine(to: CGPoint(x: cx + 46, y: cy - 72))
        earRight.addLine(to: CGPoint(x: cx + 14, y: cy - 42))
        earRight.closeSubpath()
        context.fill(earRight, with: .color(foxOrange))

        // Inner white fluff
        var innerLeft = Path()
        innerLeft.move(to: CGPoint(x: cx - 48, y: cy - 20))
        innerLeft.addLine(to: CGPoint(x: cx - 42, y: cy - 58))
        innerLeft.addLine(to: CGPoint(x: cx - 22, y: cy - 40))
        innerLeft.closeSubpath()
        context.fill(innerLeft, with: .color(foxWhite))

        var innerRight = Path()
        innerRight.move(to: CGPoint(x: cx + 48, y: cy - 20))
        innerRight.addLine(to: CGPoint(x: cx + 42, y: cy - 58))
        innerRight.addLine(to: CGPoint(x: cx + 22, y: cy - 40))
        innerRight.closeSubpath()
        context.fill(innerRight, with: .color(foxWhite))

        // Head
        let headRect = CGRect(x: cx - 58, y: cy - 58, width: 116, height: 116)
        context.fill(Path(ellipseIn: headRect), with: .color(foxOrange))

        // Muzzle
        var muzzle = Path()
        muzzle.move(to: CGPoint(x: cx - 50, y: cy + 12))
        muzzle.addQuadCurve(to: CGPoint(x: cx, y: cy + 44), control: CGPoint(x: cx - 36, y: cy + 48))
        muzzle.addQuadCurve(to: CGPoint(x: cx + 50, y: cy + 12), control: CGPoint(x: cx + 36, y: cy + 48))
        muzzle.addQuadCurve(to: CGPoint(x: cx, y: cy + 2), control: CGPoint(x: cx + 30, y: cy - 6))
        muzzle.addQuadCurve(to: CGPoint(x: cx - 50, y: cy + 12), control: CGPoint(x: cx - 30, y: cy - 6))
        muzzle.closeSubpath()
        context.fill(muzzle, with: .color(foxWhite))

        // Eyes
        let eyeY = cy - 4
        if mood == .happy {
            let leftArc = Path { p in p.addArc(center: CGPoint(x: cx - 24, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            let rightArc = Path { p in p.addArc(center: CGPoint(x: cx + 24, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            context.stroke(leftArc, with: .color(darkTip), lineWidth: 3.5)
            context.stroke(rightArc, with: .color(darkTip), lineWidth: 3.5)
        } else {
            context.fill(Path(ellipseIn: CGRect(x: cx - 31, y: eyeY - 7, width: 14, height: 14)), with: .color(darkTip))
            context.fill(Path(ellipseIn: CGRect(x: cx + 17, y: eyeY - 7, width: 14, height: 14)), with: .color(darkTip))
            context.fill(Path(ellipseIn: CGRect(x: cx - 28, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx + 20, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
        }

        // Cheeks
        context.fill(Path(ellipseIn: CGRect(x: cx - 48, y: cy + 6, width: 20, height: 20)), with: .color(Color(hex: 0xFFFF8A80).opacity(0.65)))
        context.fill(Path(ellipseIn: CGRect(x: cx + 28, y: cy + 6, width: 20, height: 20)), with: .color(Color(hex: 0xFFFF8A80).opacity(0.65)))

        // Nose
        context.fill(Path(ellipseIn: CGRect(x: cx - 7, y: cy + 14, width: 14, height: 10)), with: .color(darkTip))

        // Mouth
        drawMouth(context: context, cx: cx, cy: cy + 26, mood: mood, chewProgress: chewProgress)
    }

    // MARK: - Panda
    private func drawPanda(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        let blackColor = Color(hex: 0xFF212121)

        // Ears
        context.fill(Path(ellipseIn: CGRect(x: cx - 74, y: cy - 68, width: 52, height: 52)), with: .color(blackColor))
        context.fill(Path(ellipseIn: CGRect(x: cx + 22, y: cy - 68, width: 52, height: 52)), with: .color(blackColor))

        // White Head
        let headRect = CGRect(x: cx - 62, y: cy - 62, width: 124, height: 124)
        context.fill(Path(ellipseIn: headRect), with: .color(.white))
        context.stroke(Path(ellipseIn: headRect), with: .color(Color(hex: 0xFFECEFF1)), lineWidth: 3)

        // Eye Patches
        context.fill(Path(ellipseIn: CGRect(x: cx - 44, y: cy - 20, width: 28, height: 36)), with: .color(blackColor))
        context.fill(Path(ellipseIn: CGRect(x: cx + 16, y: cy - 20, width: 28, height: 36)), with: .color(blackColor))

        // Eyes
        let eyeY = cy - 4
        if mood == .happy {
            let leftArc = Path { p in p.addArc(center: CGPoint(x: cx - 30, y: eyeY), radius: 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            let rightArc = Path { p in p.addArc(center: CGPoint(x: cx + 30, y: eyeY), radius: 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            context.stroke(leftArc, with: .color(.white), lineWidth: 3)
            context.stroke(rightArc, with: .color(.white), lineWidth: 3)
        } else {
            context.fill(Path(ellipseIn: CGRect(x: cx - 36, y: eyeY - 6, width: 12, height: 12)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx + 24, y: eyeY - 6, width: 12, height: 12)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx - 32, y: eyeY - 3, width: 7, height: 7)), with: .color(blackColor))
            context.fill(Path(ellipseIn: CGRect(x: cx + 26, y: eyeY - 3, width: 7, height: 7)), with: .color(blackColor))
        }

        // Cheeks
        context.fill(Path(ellipseIn: CGRect(x: cx - 54, y: cy + 6, width: 24, height: 24)), with: .color(Color(hex: 0xFFFFB2C9).opacity(0.75)))
        context.fill(Path(ellipseIn: CGRect(x: cx + 30, y: cy + 6, width: 24, height: 24)), with: .color(Color(hex: 0xFFFFB2C9).opacity(0.75)))

        // Nose
        context.fill(Path(ellipseIn: CGRect(x: cx - 9, y: cy + 6, width: 18, height: 12)), with: .color(blackColor))

        // Mouth
        drawMouth(context: context, cx: cx, cy: cy + 18, mood: mood, chewProgress: chewProgress)
    }

    // MARK: - Puppy
    private func drawPuppy(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        let earColor = Color(hex: 0xFFC67D34)
        let headColor = Color(hex: 0xFFFFE0B2)
        let darkBrown = Color(hex: 0xFF3E2723)

        // Droopy Ears
        let leftEar = Path(roundedRect: CGRect(x: cx - 68, y: cy - 35, width: 26, height: 56), cornerRadius: 14)
        let rightEar = Path(roundedRect: CGRect(x: cx + 42, y: cy - 35, width: 26, height: 56), cornerRadius: 14)
        context.fill(leftEar, with: .color(earColor))
        context.fill(rightEar, with: .color(earColor))

        // Head
        let headRect = CGRect(x: cx - 60, y: cy - 60, width: 120, height: 120)
        context.fill(Path(ellipseIn: headRect), with: .color(headColor))

        // Spot over left eye
        context.fill(Path(ellipseIn: CGRect(x: cx - 46, y: cy - 30, width: 44, height: 44)), with: .color(earColor.opacity(0.6)))

        // Eyes
        let eyeY = cy - 8
        if mood == .happy {
            let leftArc = Path { p in p.addArc(center: CGPoint(x: cx - 24, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            let rightArc = Path { p in p.addArc(center: CGPoint(x: cx + 24, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            context.stroke(leftArc, with: .color(darkBrown), lineWidth: 3.5)
            context.stroke(rightArc, with: .color(darkBrown), lineWidth: 3.5)
        } else {
            context.fill(Path(ellipseIn: CGRect(x: cx - 31, y: eyeY - 7, width: 14, height: 14)), with: .color(darkBrown))
            context.fill(Path(ellipseIn: CGRect(x: cx + 17, y: eyeY - 7, width: 14, height: 14)), with: .color(darkBrown))
            context.fill(Path(ellipseIn: CGRect(x: cx - 28, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx + 20, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
        }

        // Cheeks
        context.fill(Path(ellipseIn: CGRect(x: cx - 47, y: cy + 5, width: 22, height: 22)), with: .color(Color(hex: 0xFFFFAB91).opacity(0.7)))
        context.fill(Path(ellipseIn: CGRect(x: cx + 25, y: cy + 5, width: 22, height: 22)), with: .color(Color(hex: 0xFFFFAB91).opacity(0.7)))

        // Black button nose
        context.fill(Path(ellipseIn: CGRect(x: cx - 10, y: cy + 4, width: 20, height: 13)), with: .color(Color(hex: 0xFF212121)))

        // Mouth
        drawMouth(context: context, cx: cx, cy: cy + 18, mood: mood, chewProgress: chewProgress)
    }

    // MARK: - Kitty
    private func drawKitty(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        let bodyColor = Color(hex: 0xFFFFCC80)

        // Pointy Ears
        var earLeft = Path()
        earLeft.move(to: CGPoint(x: cx - 52, y: cy - 10))
        earLeft.addLine(to: CGPoint(x: cx - 42, y: cy - 62))
        earLeft.addLine(to: CGPoint(x: cx - 12, y: cy - 40))
        earLeft.closeSubpath()
        context.fill(earLeft, with: .color(bodyColor))

        var earRight = Path()
        earRight.move(to: CGPoint(x: cx + 12, y: cy - 40))
        earRight.addLine(to: CGPoint(x: cx + 42, y: cy - 62))
        earRight.addLine(to: CGPoint(x: cx + 52, y: cy - 10))
        earRight.closeSubpath()
        context.fill(earRight, with: .color(bodyColor))

        // Inner Pink
        var innerLeft = Path()
        innerLeft.move(to: CGPoint(x: cx - 46, y: cy - 14))
        innerLeft.addLine(to: CGPoint(x: cx - 40, y: cy - 50))
        innerLeft.addLine(to: CGPoint(x: cx - 20, y: cy - 36))
        innerLeft.closeSubpath()
        context.fill(innerLeft, with: .color(Color(hex: 0xFFFF80AB)))

        var innerRight = Path()
        innerRight.move(to: CGPoint(x: cx + 20, y: cy - 36))
        innerRight.addLine(to: CGPoint(x: cx + 40, y: cy - 50))
        innerRight.addLine(to: CGPoint(x: cx + 46, y: cy - 14))
        innerRight.closeSubpath()
        context.fill(innerRight, with: .color(Color(hex: 0xFFFF80AB)))

        // Head
        let headRect = CGRect(x: cx - 58, y: cy - 58, width: 116, height: 116)
        context.fill(Path(ellipseIn: headRect), with: .color(bodyColor))

        // Eyes
        let eyeY = cy - 6
        if mood == .happy {
            let leftArc = Path { p in p.addArc(center: CGPoint(x: cx - 22, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            let rightArc = Path { p in p.addArc(center: CGPoint(x: cx + 22, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            context.stroke(leftArc, with: .color(Color(hex: 0xFF424242)), lineWidth: 3.5)
            context.stroke(rightArc, with: .color(Color(hex: 0xFF424242)), lineWidth: 3.5)
        } else {
            let tealColor = Color(hex: 0xFF00897B)
            context.fill(Path(ellipseIn: CGRect(x: cx - 29, y: eyeY - 7, width: 14, height: 14)), with: .color(tealColor))
            context.fill(Path(ellipseIn: CGRect(x: cx + 15, y: eyeY - 7, width: 14, height: 14)), with: .color(tealColor))
            context.fill(Path(ellipseIn: CGRect(x: cx - 26, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx + 18, y: eyeY - 5, width: 5, height: 5)), with: .color(.white))
        }

        // Whiskers
        var whiskers = Path()
        whiskers.move(to: CGPoint(x: cx - 34, y: cy + 12)); whiskers.addLine(to: CGPoint(x: cx - 62, y: cy + 8))
        whiskers.move(to: CGPoint(x: cx - 34, y: cy + 20)); whiskers.addLine(to: CGPoint(x: cx - 62, y: cy + 24))
        whiskers.move(to: CGPoint(x: cx + 34, y: cy + 12)); whiskers.addLine(to: CGPoint(x: cx + 62, y: cy + 8))
        whiskers.move(to: CGPoint(x: cx + 34, y: cy + 20)); whiskers.addLine(to: CGPoint(x: cx + 62, y: cy + 24))
        context.stroke(whiskers, with: .color(Color(hex: 0xFF757575)), lineWidth: 2.5)

        // Pink tiny nose
        context.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy + 4, width: 8, height: 8)), with: .color(.pinkStrawberry))

        // Mouth
        drawMouth(context: context, cx: cx, cy: cy + 16, mood: mood, chewProgress: chewProgress)
    }

    // MARK: - Bunny
    private func drawBunny(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        // Long White Ears
        let leftEar = Path(roundedRect: CGRect(x: cx - 32, y: cy - 82, width: 20, height: 62), cornerRadius: 10)
        let rightEar = Path(roundedRect: CGRect(x: cx + 12, y: cy - 82, width: 20, height: 62), cornerRadius: 10)
        context.fill(leftEar, with: .color(.white))
        context.fill(rightEar, with: .color(.white))

        let leftInner = Path(roundedRect: CGRect(x: cx - 28, y: cy - 76, width: 12, height: 48), cornerRadius: 6)
        let rightInner = Path(roundedRect: CGRect(x: cx + 16, y: cy - 76, width: 12, height: 48), cornerRadius: 6)
        let pinkInner = Color(hex: 0xFFFF80AB)
        context.fill(leftInner, with: .color(pinkInner))
        context.fill(rightInner, with: .color(pinkInner))

        // Head
        let headRect = CGRect(x: cx - 56, y: cy - 56, width: 112, height: 112)
        context.fill(Path(ellipseIn: headRect), with: .color(.white))
        context.stroke(Path(ellipseIn: headRect), with: .color(Color(hex: 0xFFECEFF1)), lineWidth: 3)

        // Eyes
        let eyeY = cy - 6
        let darkEye = Color(hex: 0xFF37474F)
        if mood == .happy {
            let leftArc = Path { p in p.addArc(center: CGPoint(x: cx - 20, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            let rightArc = Path { p in p.addArc(center: CGPoint(x: cx + 20, y: eyeY), radius: 8, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false) }
            context.stroke(leftArc, with: .color(darkEye), lineWidth: 3.5)
            context.stroke(rightArc, with: .color(darkEye), lineWidth: 3.5)
        } else {
            context.fill(Path(ellipseIn: CGRect(x: cx - 26, y: eyeY - 6, width: 13, height: 13)), with: .color(darkEye))
            context.fill(Path(ellipseIn: CGRect(x: cx + 13, y: eyeY - 6, width: 13, height: 13)), with: .color(darkEye))
            context.fill(Path(ellipseIn: CGRect(x: cx - 24, y: eyeY - 4, width: 5, height: 5)), with: .color(.white))
            context.fill(Path(ellipseIn: CGRect(x: cx + 15, y: eyeY - 4, width: 5, height: 5)), with: .color(.white))
        }

        // Cheeks
        context.fill(Path(ellipseIn: CGRect(x: cx - 42, y: cy + 4, width: 20, height: 20)), with: .color(pinkInner.opacity(0.6)))
        context.fill(Path(ellipseIn: CGRect(x: cx + 22, y: cy + 4, width: 20, height: 20)), with: .color(pinkInner.opacity(0.6)))

        // Pink nose
        context.fill(Path(ellipseIn: CGRect(x: cx - 4, y: cy + 2, width: 8, height: 8)), with: .color(.pinkStrawberry))

        // Mouth
        drawMouth(context: context, cx: cx, cy: cy + 16, mood: mood, chewProgress: chewProgress)
    }

    // MARK: - Mouth
    private func drawMouth(context: GraphicsContext, cx: CGFloat, cy: CGFloat, mood: AnimalMood, chewProgress: CGFloat) {
        if mood == .eating {
            let mouthHeight = 12 + chewProgress * 12
            let mouthRect = CGRect(x: cx - 10, y: cy, width: 20, height: mouthHeight)
            context.fill(Path(ellipseIn: mouthRect), with: .color(Color(hex: 0xFFD81B60)))
            context.fill(Path(ellipseIn: CGRect(x: cx - 5, y: cy + mouthHeight * 0.4, width: 10, height: 10)), with: .color(Color(hex: 0xFFFF80AB)))
        } else if mood == .happy {
            let smileRect = CGRect(x: cx - 14, y: cy - 2, width: 28, height: 18)
            var smile = Path()
            smile.addArc(center: CGPoint(x: cx, y: cy + 4), radius: 12, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            smile.closeSubpath()
            context.fill(smile, with: .color(Color(hex: 0xFF212121)))
            context.fill(Path(ellipseIn: CGRect(x: cx - 6, y: cy + 6, width: 12, height: 8)), with: .color(.pinkStrawberry))
        } else {
            var path = Path()
            path.move(to: CGPoint(x: cx - 10, y: cy))
            path.addQuadCurve(to: CGPoint(x: cx, y: cy), control: CGPoint(x: cx - 5, y: cy + 6))
            path.addQuadCurve(to: CGPoint(x: cx + 10, y: cy), control: CGPoint(x: cx + 5, y: cy + 6))
            context.stroke(path, with: .color(Color(hex: 0xFF212121)), lineWidth: 2.5)
        }
    }

    // MARK: - Heart
    private func drawHeart(context: GraphicsContext, center: CGPoint, color: Color, size: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y + size * 0.4))
        path.addCurve(to: CGPoint(x: center.x, y: center.y - size * 0.3),
                      control1: CGPoint(x: center.x - size, y: center.y - size * 0.6),
                      control2: CGPoint(x: center.x - size * 0.5, y: center.y - size))
        path.addCurve(to: CGPoint(x: center.x, y: center.y + size * 0.4),
                      control1: CGPoint(x: center.x + size * 0.5, y: center.y - size),
                      control2: CGPoint(x: center.x + size, y: center.y - size * 0.6))
        path.closeSubpath()
        context.fill(path, with: .color(color))
    }
}

// MARK: - Order Bubble Matching Android OrderBubble.kt
struct OrderBubbleView: View {
    let desiredDessertEmoji: String
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Text(desiredDessertEmoji)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 2) {
                Text("I'm hungry!")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.textDark)
                Text(message)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.pinkStrawberry, lineWidth: 2))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
