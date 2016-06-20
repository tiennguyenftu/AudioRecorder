//
//  ViewController.swift
//  AudioDemo


import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var stopButton:UIButton!
    @IBOutlet weak var recordButton:UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    let audioSession = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.enabled = false
        playButton.enabled = false
        
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recoding the audio. Please try again", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            return
        }
        
        let audioFileURL = directoryURL.URLByAppendingPathComponent("MyAudioMemo.m4a")
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
            
            let recorderSetting: [String: AnyObject] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
            audioRecorder = try AVAudioRecorder(URL: audioFileURL, settings: recorderSetting)
            audioRecorder?.delegate = self
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print(error)
        }
    }

    @IBAction func play(sender: AnyObject) {
        if let recorder = audioRecorder {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: recorder.url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                
                playButton.setImage(UIImage(named: "playing"), forState: .Selected)
                playButton.selected = true
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        recordButton.setImage(UIImage(named: "record"), forState: .Normal)
        recordButton.selected = false
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
        playButton.selected = false
        
        stopButton.enabled = false
        playButton.enabled = true
        
        audioRecorder?.stop()
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }
    
    @IBAction func record(sender: AnyObject) {
        if let player = audioPlayer {
            if player.playing {
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: .Normal)
                playButton.selected = false
            }
        }
        
        if let recorder = audioRecorder {
            if !recorder.recording {
                
                do {
                    try audioSession.setActive(true)
                    
                    recorder.record()
                    recordButton.setImage(UIImage(named: "recording"), forState: .Selected)
                    recordButton.selected = true
                } catch {
                    print(error)
                }
            } else {
                recorder.pause()
                recordButton.setImage(UIImage(named: "pause"), forState: .Normal)
                recordButton.selected = false
            }
        }
        
        stopButton.enabled = true
        playButton.enabled = false
    }
    
    //MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish Recording", message: "Successfully recorded the audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    //MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
       playButton.setImage(UIImage(named: "play"), forState: .Normal)
        playButton.selected = false
        
        let alertMessage = UIAlertController(title: "Finish Playing", message: "Finish playing the recording!", preferredStyle: .Alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertMessage, animated: true, completion: nil)
    }
}

