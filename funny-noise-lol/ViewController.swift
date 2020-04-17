//
//  ViewController.swift
//  funny-noise-lol
//
//  Created by Roy Smith on 4/16/20.
//  Copyright © 2020 Roy Smith. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // accepted
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func startRecording() {
        let audioFilename = createAudioRecordPath()

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            // audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    @IBAction func pressRecord(_ sender: UIButton) {
        if (sender.titleLabel!.text == "Record") {
            // Start recording
            startRecording()
            
            sender.setTitle("Stop", for: .normal)
            sender.setBackgroundImage(UIImage(systemName: "square.fill"), for: .normal)
        } else {
            // Stop recording
            
            finishRecording()
            
            sender.setTitle("Record", for: .normal)
            sender.setBackgroundImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
    }
    
    @IBAction func pressPlay(_ sender: UIButton) {
        do {
            let url = try getRandomURL()
            if url != nil {
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer.volume = 1
                audioPlayer.play()
            }
        } catch {
            print("Error: failed to play file \(error)")
        }
    }
    
    @IBAction func trashPressed(_ sender: UIButton) {
        clearAllFilesFromDirectory()
    }
    
    // Helper functions
    
    private func getRandomURL() throws -> URL? {
        let urls = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil)
        return urls.randomElement()
    }
    
    private func createAudioRecordPath() -> URL {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss-SSS"
        let currentFileName = "recording-\(format.string(from: Date()))" + ".m4a"
        let url = getDocumentsDirectory().appendingPathComponent(currentFileName)
        return url
    }
    
    func clearAllFilesFromDirectory(){
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil)
            
            for url in urls {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("Error: Failed to clear files from directory \(error)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.temporaryDirectory
    }

}

