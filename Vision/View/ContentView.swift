//
//  ContentView.swift
//  Vision
//
//  Created by Rahul on 09/12/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var poseEstimator = PoseEstimator()
    
    var body: some View {
        VStack {
            ZStack {
                GeometryReader { geo in
                    CameraViewWrapper(poseEstimator: poseEstimator)
                    StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                }
//                HStack {
//                    Text("왼쪽 팔각도:")
//                        .font(.system(size: 30))
//                        .foregroundColor(.blue)
//                    if #available(iOS 15.0, *) {
//                        Text(String(poseEstimator.leftAngle))
//                            .font(.system(size: 60))
//                            .foregroundColor(.red)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//                    Text("오른쪽 팔각도:")
//                        .font(.system(size: 30))
//                        .foregroundColor(.blue)
//                    if #available(iOS 15.0, *) {
//                        Text(String(poseEstimator.rightAngle))
//                            .font(.system(size: 60))
//                            .foregroundColor(.red)
//                    } else {
//                        // Fallback on earlier versions
//                    }
//    //                    Image(systemName: "exclamationmark.triangle.fill")
//    //                        .font(.largeTitle)
//    //                        .foregroundColor(Color.red)
//    //                        .opacity(poseEstimator.isGoodPosture ? 0.0 : 1.0)
//                }
            }.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width * 1920 / 1080, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}



struct Toast: ViewModifier {
  // these correspond to Android values f
  // or DURATION_SHORT and DURATION_LONG
  static let short: TimeInterval = 2
  static let long: TimeInterval = 3.5

  let message: String
  @Binding var isShowing: Bool
  let config: Config

  func body(content: Content) -> some View {
    ZStack {
      content
      toastView
    }
  }

  private var toastView: some View {
    VStack {
      Spacer()
      if isShowing {
        Group {
          Text(message)
            .multilineTextAlignment(.center)
            .foregroundColor(config.textColor)
            .font(config.font)
            .padding(8)
        }
        .background(config.backgroundColor)
        .cornerRadius(8)
        .onTapGesture {
          isShowing = false
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
            isShowing = false
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 18)
    .animation(config.animation, value: isShowing)
    .transition(config.transition)
  }

  struct Config {
    let textColor: Color
    let font: Font
    let backgroundColor: Color
    let duration: TimeInterval
    let transition: AnyTransition
    let animation: Animation

    init(textColor: Color = .white,
         font: Font = .system(size: 14),
         backgroundColor: Color = .black.opacity(0.588),
         duration: TimeInterval = Toast.short,
         transition: AnyTransition = .opacity,
         animation: Animation = .linear(duration: 0.3)) {
      self.textColor = textColor
      self.font = font
      self.backgroundColor = backgroundColor
      self.duration = duration
      self.transition = transition
      self.animation = animation
    }
  }
}

extension View {
  func toast(message: String,
             isShowing: Binding<Bool>,
             config: Toast.Config) -> some View {
    self.modifier(Toast(message: message,
                        isShowing: isShowing,
                        config: config))
  }

  func toast(message: String,
             isShowing: Binding<Bool>,
             duration: TimeInterval) -> some View {
    self.modifier(Toast(message: message,
                        isShowing: isShowing,
                        config: .init(duration: duration)))
  }
}
