import SwiftUI

struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                // Right leg
//                Stick(points: [poseEstimator.bodyParts[.neck]!.location, CGPoint(x: poseEstimator.bodyParts[.neck]!.location.x, y: poseEstimator.bodyParts[.neck]!.location.y + 0.25)], size: size)
//                    .stroke(lineWidth: 5.0)
//                    .fill(Color.green)
//                Stick(points: [CGPoint(x: (poseEstimator.bodyParts[.rightEar]!.location.x + poseEstimator.bodyParts[.leftEar]!.location.x) / 2, y: (poseEstimator.bodyParts[.rightEar]!.location.y + poseEstimator.bodyParts[.leftEar]!.location.y) / 2 + 0.05), CGPoint(x: poseEstimator.bodyParts[.neck]!.location.x, y: poseEstimator.bodyParts[.neck]!.location.y)], size: size)
//                    .stroke(lineWidth: 5.0)
//                    .fill(Color.red)
                // Left leg
                Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location, poseEstimator.bodyParts[.leftKnee]!.location, poseEstimator.bodyParts[.leftHip]!.location,
                               poseEstimator.bodyParts[.root]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Right arm
                Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location, poseEstimator.bodyParts[.rightElbow]!.location, poseEstimator.bodyParts[.rightShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Left arm
                Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location, poseEstimator.bodyParts[.leftElbow]!.location, poseEstimator.bodyParts[.leftShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Root to nose
                Stick(points: [poseEstimator.bodyParts[.root]!.location,
                               poseEstimator.bodyParts[.neck]!.location,  poseEstimator.bodyParts[.nose]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                
                CustomCircle(size: size, point: poseEstimator.bodyParts[.nose]!.location)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.red)
                
                Text("This")
                    .lineLimit(3)
                    .position(x: poseEstimator.bodyParts[.nose]!.location.x, y: poseEstimator.bodyParts[.nose]!.location.y)
                
                }
        } else {
            
        }
    }
}

