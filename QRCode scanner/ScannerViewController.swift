//
//  ScannerViewController.swift
//  QRCode scanner
//
//  Created by Prashant G on 1/8/19.
//  Copyright © 2019 Prashant G. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK: - IBOutlets
    @IBOutlet var videoPreview: UIView!
    
    //MARK: - Properties
    var stringURL: String!
    let avcaptureSession = AVCaptureSession()
    var avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try scanQRCode()
        }catch {
            print("Failed to scan the QR Code")
        }
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        avCaptureVideoPreviewLayer.frame = self.videoPreview.bounds
    }
    
    //MARK: - Custom Actions
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if machineReadableCode.type == .qr {
                stringURL = machineReadableCode.stringValue
                //TODO: open safari
                showSafariVC(for: stringURL)
            }
        }
    }
    
    func scanQRCode() throws {
        
        guard let avcaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("No camera")
            throw error.noCameraAvailable
        }
        
        guard let avcaptureInput = try? AVCaptureDeviceInput(device: avcaptureDevice) else {
            print("Failed to init camera")
            throw error.videoInputInitFail
        }
        
        let avcaptureMetaDataOutput = AVCaptureMetadataOutput()
        avcaptureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        avcaptureSession.addInput(avcaptureInput)
        avcaptureSession.addOutput(avcaptureMetaDataOutput)
        
        avcaptureMetaDataOutput.metadataObjectTypes = [.qr]
        
        avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avcaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = .resizeAspect
        avCaptureVideoPreviewLayer.frame = self.videoPreview.bounds
        
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        avcaptureSession.startRunning()
        
        
    }
    
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            // Show an invalid URL error
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
}
