import Foundation
import AVFoundation
import Vision
import Combine


enum HandsPosition{
    case up
    case down
}

enum DeadLiftPostion{
    case up
    case down
}


class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()
    var wasInBottomPosition = false
    var wasInTopPosition = false
    var handsPosition: HandsPosition = .down
    var deadLiftPosition: DeadLiftPostion = .down
    @Published var squatCount = 0
    
    @Published var leftAngle = 0
    @Published var rightAngle = 0
    
    @Published var isGoodPosture = true
    
    var subscriptions = Set<AnyCancellable>()
    var check = true
    
    override init() {
        super.init()
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { bodyParts in
//                print("bodyParts", bodyParts)
                if self.check {
                    self.countSquats(bodyParts: bodyParts)
                    self.check = false
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                    self.check = true
                }
            })
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(
                [humanBodyRequest],
                on: sampleBuffer,
                orientation: .right)
        } catch {
            print(error.localizedDescription)
        }
    }
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation]
        else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func countSquats(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        
        let rightKnee = bodyParts[.rightKnee]!.location
        let leftKnee = bodyParts[.rightKnee]!.location
        let leftHip = bodyParts[.leftHip]!.location
        let rightHip = bodyParts[.rightHip]!.location
        let rightAnkle = bodyParts[.rightAnkle]!.location
        let leftAnkle = bodyParts[.leftAnkle]!.location
        
        let rightShoulder = bodyParts[.rightShoulder]!.location
        let rightWrist = bodyParts[.rightWrist]!.location
        let leftShoulder = bodyParts[.leftShoulder]!.location
        let leftWrist = bodyParts[.leftWrist]!.location
        
//        let firstAngle = atan2(rightShoulder.y - rightWrist.y, rightShoulder.x - rightShoulder.x)
//        let secondAngle = atan2(leftShoulder.y - leftWrist.y, leftShoulder.y - leftShoulder.x)
        
        let firstAngle = atan((leftWrist.y - leftShoulder.y) / (leftWrist.x - leftShoulder.x))
        let secondAngle = atan((rightWrist.y - rightShoulder.y) / (rightWrist.x - rightShoulder.x))
        
        if firstAngle <= 180, secondAngle <= 180 {
            leftAngle = abs(Int(firstAngle * 180 / .pi) + 90)
            rightAngle = abs(Int(secondAngle * 180 / .pi) - 90)
        }
        
        
//        let firstAngle = atan2(rightHip.y - rightKnee.y, rightHip.x - rightKnee.x)
//        let secondAngle = atan2(rightAnkle.y - rightKnee.y, rightAnkle.x - rightKnee.x)
//        var angleDiffRadians = firstAngle - secondAngle
//        while angleDiffRadians < 0 {
//            angleDiffRadians += CGFloat(2 * Double.pi)
//        }
//        let angleDiffDegrees = Int(angleDiffRadians * 180 / .pi)
//        print(angleDiffDegrees)
        
        
//        if self.wasInBottomPosition && self.wasInTopPosition {
//
//
//            self.squatCount += 1
//            print("squatCount: \(self.squatCount)")
//            print("false")
//            self.wasInBottomPosition = false
//            self.wasInTopPosition = false
//        }
//
//        let hipKneeDiff = rightHip.y / rightKnee.y
//        let rightWristShoulderDiff = rightShoulder.y / rightWrist.y
//        let leftWristShoulderDiff = leftShoulder.y / leftWrist.y
//
//        if (hipKneeDiff > 0.80 && hipKneeDiff < 1.3) &&
//            (rightWristShoulderDiff > 0.85 && rightWristShoulderDiff < 1.15) &&
//            (leftWristShoulderDiff > 0.85 && leftWristShoulderDiff < 1.15) {
//            print("wasInBottomPosition :   true")
//            print("wasInTopPosition :    false")
//            self.wasInBottomPosition = true
//
//            if squatCount == 0 {
//                self.wasInTopPosition = true
//            } else {
//                self.wasInTopPosition = false
//            }
//        }
//
////        print(rightShoulder.y)
//        if rightHip.y / rightKnee.y >= 1.5 {
//            print("wasInTopPosition :    true")
//            self.wasInTopPosition = true
//        }
    }
    
    
    
    //MARK:- Shoulder Press
    
    func countShoulderPress(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        
        let rightShoulder = bodyParts[.rightShoulder]!.location
        let leftShoulder = bodyParts[.leftShoulder]!.location
        let rightWrist = bodyParts[.rightWrist]!.location
        let leftWrist = bodyParts[.rightWrist]!.location
        let rightElbow = bodyParts[.rightElbow]!.location
        let leftElbow = bodyParts[.leftElbow]!.location
        let leftEye = bodyParts[.leftEye]!.location
       
        
        //find hands postion
        
        //        if rightWrist.y < rightShoulder.y && leftWrist.y < leftShoulder.y{
        //            handsPostion = .down
        //        }
        
        //        if rightWrist.y > leftEye.y && leftWrist.y > leftEye.y{
        //            let deadlineTime = DispatchTime.now() + .seconds(3)
        //            DispatchQueue.main.asyncAfter(deadline: deadlineTime){
        //                self.handsPostion = .up
        //            }
        //        }
        // print("Hand's Postion : \(String(describing: handsPostion))")
        
        
        
        //calculate elbow angles
        //        let rightHandAngle = angle(firstLandmark: rightShoulder, midLandmark: rightElbow, lastLandmark: rightWrist)
        //        let leftHandAngle = angle(firstLandmark: leftShoulder, midLandmark: leftElbow, lastLandmark: leftWrist)
        //
        //        print("Right hand angle : \(rightHandAngle)  -----------  Left hand angle : \(leftHandAngle)")
        //
        
        //check for shoulder press
        
        // 1.--------check on elbow angle
        //        if (rightHandAngle > 160) && (rightHandAngle < 180) && handsPostion == .up {
        //            self.squatCount += 1
        //            print("shoulder press count: \(self.squatCount)")
        //            self.handsPostion = .down
        //        }
        
        
        // 2.-------- check on elbow y axis
        
        if rightElbow.y > leftEye.y && leftElbow.y > leftEye.y && handsPosition == .up{
            self.squatCount += 1
            print("shoulder press count: \(self.squatCount)")
            self.handsPosition = .down
        }
        
        
        //hands postion
        if rightElbow.y < rightShoulder.y && leftElbow.y < leftShoulder.y{
            handsPosition = .up
        }
        
        print("\(bodyParts[.rightShoulder]!.location.y) ---------- \(bodyParts[.nose]!.location.y)")
        
      //  print("Hand's Position : \(String(describing: handsPosition))")
    }
    
    
    
    //MARK:- Dead Lift
    
    func countDeadLift(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        let rightShoulder = bodyParts[.rightShoulder]!.location
        let leftShoulder = bodyParts[.leftShoulder]!.location
        let rightWrist = bodyParts[.rightWrist]!.location
        let leftWrist = bodyParts[.rightWrist]!.location
        let rightElbow = bodyParts[.rightElbow]!.location
        let leftElbow = bodyParts[.leftElbow]!.location
        
        let rightHip = bodyParts[.rightHip]!.location
        let leftHip = bodyParts[.leftHip]!.location
        let rightKnee = bodyParts[.rightKnee]!.location
        let leftKnee = bodyParts[.leftKnee]!.location
        
        let rightAnkle = bodyParts[.rightAnkle]!.location
        let leftAnkle = bodyParts[.leftAnkle]!.location
        
        
        //calculate elbow angles
        let rightHandAngle = angle(firstLandmark: rightShoulder, midLandmark: rightElbow, lastLandmark: rightWrist)
        let leftHandAngle = angle(firstLandmark: leftShoulder, midLandmark: leftElbow, lastLandmark: leftWrist)
        
        //calculate hips angles
        let rightHipAngle = angle(firstLandmark: rightShoulder, midLandmark: rightHip, lastLandmark: rightKnee)
        let leftHipAngle = angle(firstLandmark: leftShoulder, midLandmark: leftHip, lastLandmark: leftKnee)
        
        
        
        //1.------for up position
        
        //hand's position
        if rightHandAngle > 160 && rightHandAngle < 180 && leftHandAngle > 160 && leftHandAngle < 180 && rightElbow.y > rightHip.y && leftElbow.y > leftHip.y && deadLiftPosition == .up{
            
            //hip's position
            if rightHipAngle > 170 && rightHipAngle < 180 && leftHipAngle > 170 && leftHipAngle < 180{
                
                //Foot gap
                if leftAnkle.x >= leftShoulder.x && rightAnkle.x >= rightShoulder.x{
                    squatCount += 1
                    print("deadLift count: \(self.squatCount)")
                    deadLiftPosition = .down
                }
         
            }
            
        }
        
        
        
        //2.------for down position
        //hand's position
        if rightHandAngle > 160 && rightHandAngle < 180 && leftHandAngle > 160 && leftHandAngle < 180 && rightElbow.y < rightHip.y && leftElbow.y < leftHip.y && deadLiftPosition == .down{
            
            //hip's position
            if rightHipAngle > 45 && rightHipAngle < 70 && leftHipAngle > 45 && leftHipAngle < 70{
                
                //Foot gap
                if leftAnkle.x >= leftShoulder.x && rightAnkle.x >= rightShoulder.x{
                    deadLiftPosition = .up
                }
         
            }
            
        }
        
        print("body Position : \(String(describing: handsPosition))")
        
        
    }
    
    
    
    func angle(
        firstLandmark: CGPoint,
        midLandmark: CGPoint,
        lastLandmark: CGPoint
    ) -> CGFloat {
        let radians: CGFloat =
        atan2(lastLandmark.y - midLandmark.y,
              lastLandmark.x - midLandmark.x) -
        atan2(firstLandmark.y - midLandmark.y,
              firstLandmark.x - midLandmark.x)
        var degrees = radians * 180.0 / .pi
        degrees = abs(degrees) // Angle should never be negative
        if degrees > 180.0 {
            degrees = 360.0 - degrees // Always get the acute representation of the angle
        }
        return degrees
    }
    
    
}
