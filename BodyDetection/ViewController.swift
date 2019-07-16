/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    @IBOutlet weak var messageLabel: MessageLabel!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character //-1.0 by one meter to the left
    let characterAnchor = AnchorEntity()
    
    // A tracked raycast which is used to place the character accurately
    // in the scene wherever the user taps.
    var placementRaycast: ARTrackedRaycast?
    var tapPlacementAnchor: AnchorEntity?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        print("hello world")
        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        
        // Asynchronously load the 3D character.
        _ = Entity.loadBodyTrackedAsync(named: "character/robot").sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                print("Error: Unable to load model: \(error.localizedDescription)")
            }
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }

            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
            let hipWorldPosition = bodyAnchor.transform
            //print("hipPosition", hipWorldPosition)
            let skeleton = bodyAnchor.skeleton
            let jointTransforms = skeleton.jointModelTransforms
            
            //print("JointNames", skeleton.definition.jointNames)
            //print("Joint", skeleton.jointLocalTransforms.)
            //print("jointTransforms", jointTransforms)
            print("indices", skeleton.definition.parentIndices)
            
            let footIndex = ARSkeletonDefinition.defaultBody3D.index(for: .rightFoot)
            let footTransform = ARSkeletonDefinition.defaultBody3D.neutralBodySkeleton3D!.jointModelTransforms[footIndex]
            print("footTransform", footTransform)
            let distanceFromHipOnY = abs(footTransform.columns.3.y)
            print (distanceFromHipOnY)

            for (i, jointTransform) in jointTransforms.enumerated() {
                let parentIndex = skeleton.definition.parentIndices[ i ]
                guard parentIndex != -1 else { continue }
                let parentJointTransform = jointTransforms[parentIndex]
                //print("parentJointTransform", parentJointTransform)
            }
            
        }
    }
}


//
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        // Accessing ARBody2D Object from ARFrame
//        let person = frame.detectedBody
//
//        // USe Skeleton Property to Access the Skeleton
//        let skeleton2D = person?.skeleton
//
//        // Access Definition Object containing structure
//        let definition = skeleton2D?.definition
//
//        //List of JointLandmarks
//        let jointLandmarks = skeleton2D?.jointLandmarks
//        print(jointLandmarks)
//
//        //Iterate over all landmarks
//        for (i, joint) in jointLandmarks.enumerate() {
//            // Find index of parent
//            let parentIndex = definition.parentIndices[i]
//
//            // check if it's not the root
//            guard parentIndex != -1 else {continue}
//
//            // find position of parent index
//            let parentJoint = jointLandmarks [parentIndex.intValue]
//        }
//    }
