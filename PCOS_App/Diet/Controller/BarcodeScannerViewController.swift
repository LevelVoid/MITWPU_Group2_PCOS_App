import UIKit
import AVFoundation

protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
    
}


class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: BarcodeScannerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        captureSession = AVCaptureSession() // 1. Camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput = try! AVCaptureDeviceInput(device: videoCaptureDevice)

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add camera input")
            return
        }   // 2. Barcode output
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)  // Supported barcodes
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .code128, .qr,
                .upce, .code39, .code93, .pdf417
            ]
        } else {
            print("Could not add metadata output")
            return
        }   // 3. Preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)    // 4. Start scanning
        captureSession.startRunning()
    }   // 🔥 When a barcode is detected:
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        captureSession.stopRunning()

        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadataObj.stringValue {
            delegate?.didScanBarcode(code)
            dismiss(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
}
