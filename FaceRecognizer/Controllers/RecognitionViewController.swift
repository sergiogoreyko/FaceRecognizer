//
//  RecognitionViewController.swift
//  FaceRecognizer
//
//  Created by Сергей Горейко on 31.03.2021.
//

import AVFoundation
import UIKit
import Vision

class RecognitionViewController: UIViewController {
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLayers: [CAShapeLayer] = []
    private var labelLayers: [CATextLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Recognition"
        
        setupCamera()
        captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.frame
    }
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.frame
        
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        let videoConnection = self.videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
}


extension RecognitionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let faceRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored, options: [:])
        let labelRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer)
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })
                
                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations)
                }
            }
        })
        
        let visionModel = try? VNCoreMLModel(for: Testing2().model)
        let objectDetectionRequest = VNCoreMLRequest(model: visionModel!) { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.labelLayers.forEach({ drawing in drawing.removeFromSuperlayer() })
                
                if let predictions = request.results as? [VNRecognizedObjectObservation] {
                    self.handleFaceRecognitionPredictions(predictions: predictions)
                }
            }
        }
        
        do {
            try faceRequestHandler.perform([faceDetectionRequest])
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try labelRequestHandler.perform([objectDetectionRequest])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - FACE LOCALIZATION
    
    private func handleFaceDetectionObservations(observations: [VNFaceObservation]) {
        for observation in observations {
            let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
            let faceRectanglePath = CGPath(rect: faceRectConverted, transform: nil)
            
            let faceLayer = CAShapeLayer()
            faceLayer.path = faceRectanglePath
            faceLayer.fillColor = UIColor.clear.cgColor
            faceLayer.strokeColor = UIColor.yellow.cgColor
            
            self.faceLayers.append(faceLayer)
            self.view.layer.addSublayer(faceLayer)
            
            // FACE LANDMARKS
            if let landmarks = observation.landmarks {
                if let leftEye = landmarks.leftEye {
                    self.handleLandmark(leftEye, faceBoundingBox: faceRectConverted)
                }
                if let leftEyebrow = landmarks.leftEyebrow {
                    self.handleLandmark(leftEyebrow, faceBoundingBox: faceRectConverted)
                }
                if let rightEye = landmarks.rightEye {
                    self.handleLandmark(rightEye, faceBoundingBox: faceRectConverted)
                }
                if let rightEyebrow = landmarks.rightEyebrow {
                    self.handleLandmark(rightEyebrow, faceBoundingBox: faceRectConverted)
                }
                
                if let nose = landmarks.nose {
                    self.handleLandmark(nose, faceBoundingBox: faceRectConverted)
                }
                
                if let outerLips = landmarks.outerLips {
                    self.handleLandmark(outerLips, faceBoundingBox: faceRectConverted)
                }
                if let innerLips = landmarks.innerLips {
                    self.handleLandmark(innerLips, faceBoundingBox: faceRectConverted)
                }
            }
        }
    }
    
    private func handleLandmark(_ eye: VNFaceLandmarkRegion2D, faceBoundingBox: CGRect) {
        let landmarkPath = CGMutablePath()
        let landmarkPathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * faceBoundingBox.height + faceBoundingBox.origin.x,
                    y: eyePoint.x * faceBoundingBox.width + faceBoundingBox.origin.y)
            })
        landmarkPath.addLines(between: landmarkPathPoints)
        landmarkPath.closeSubpath()
        let landmarkLayer = CAShapeLayer()
        landmarkLayer.path = landmarkPath
        landmarkLayer.fillColor = UIColor.clear.cgColor
        landmarkLayer.strokeColor = UIColor.yellow.cgColor
        
        self.faceLayers.append(landmarkLayer)
        self.view.layer.addSublayer(landmarkLayer)
    }
    
    // MARK: - FACE RECOGNITION
    
    private func handleFaceRecognitionPredictions(predictions: [VNRecognizedObjectObservation]) {
        for prediction in predictions {
            let objectRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: prediction.boundingBox)
            let objectRectanglePath = CGPath(rect: objectRect, transform: nil)
            
            let objectLayer = CAShapeLayer()
            objectLayer.path = objectRectanglePath
            
            let labelLayer = CATextLayer()
            labelLayer.frame = CGRect(x: objectRect.origin.x,
                                      y: objectRect.origin.y - 5,
                                      width: objectRect.size.width,
                                      height: objectRect.size.width / 6)
            
            labelLayer.string = prediction.name
            labelLayer.fontSize = labelLayer.frame.width / 8
            labelLayer.foregroundColor = UIColor.black.cgColor
            labelLayer.backgroundColor = UIColor.green.cgColor
            labelLayer.cornerRadius = 10
            labelLayer.alignmentMode = .center
            
            self.labelLayers.append(labelLayer)
            self.view.layer.addSublayer(labelLayer)
        }
    }
}


extension VNRecognizedObjectObservation {
    var name: String? {
        return self.labels.first?.identifier
    }
}
