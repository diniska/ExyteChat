//
//  Recorder.swift
//  
//
//  Created by Alisa Mylnikova on 09.03.2023.
//

import Foundation
import AVFoundation

public final class Recorder {

    public nonisolated struct AudioSample: Codable, Equatable, Hashable {
        public var averagePower: CGFloat
        public var peakPower: CGFloat

        public init(averagePower: CGFloat, peakPower: CGFloat) {
            self.averagePower = averagePower
            self.peakPower = peakPower
        }
    }
    
    public struct AudioSamplingConfiguraion {
        public var sampleTimeInterval: TimeInterval

        public init(sampleTimeInterval: TimeInterval = 1) {
            self.sampleTimeInterval = sampleTimeInterval
        }
    }
    
    // duration and waveform samples
    public typealias ProgressHandler = (Double, [AudioSample]) -> Void

    private let audioSession = AVAudioSession()
    private var audioRecorder: AVAudioRecorder?
    private var audioTimer: Timer?

    public var recorderSettings = RecorderSettings()
    private var soundSamples: [AudioSample] = []
    public var audioSamplingConfiguration = AudioSamplingConfiguraion()

    public var isAllowedToRecordAudio: Bool {
        audioSession.recordPermission == .granted
    }

    public var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    public init() {}

    public func startRecording(durationProgressHandler: @escaping ProgressHandler) async -> URL? {
        if !isAllowedToRecordAudio {
            let granted = await audioSession.requestRecordPermission()
            if granted {
                return startRecordingInternal(durationProgressHandler)
            }
            return nil
        } else {
            return startRecordingInternal(durationProgressHandler)
        }
    }
    
    private func startRecordingInternal(_ durationProgressHandler: @escaping ProgressHandler) -> URL? {
        let settings: [String : Any] = [
            AVFormatIDKey: Int(recorderSettings.audioFormatID),
            AVSampleRateKey: recorderSettings.sampleRate,
            AVNumberOfChannelsKey: recorderSettings.numberOfChannels,
            AVEncoderBitRateKey: recorderSettings.encoderBitRateKey,
            AVLinearPCMBitDepthKey: recorderSettings.linearPCMBitDepth,
            AVLinearPCMIsFloatKey: recorderSettings.linearPCMIsFloatKey,
            AVLinearPCMIsBigEndianKey: recorderSettings.linearPCMIsBigEndianKey,
            AVLinearPCMIsNonInterleaved: recorderSettings.linearPCMIsNonInterleaved,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        soundSamples = []
        guard let fileExt = fileExtension(for: recorderSettings.audioFormatID) else{
            return nil
        }
        let recordingUrl = FileManager.tempDirPath.appendingPathComponent(UUID().uuidString + fileExt)

        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            durationProgressHandler(0.0, [])

            DispatchQueue.main.async { [weak self] in
                self?.audioTimer = Timer.scheduledTimer(withTimeInterval: self?.audioSamplingConfiguration.sampleTimeInterval ?? 1, repeats: true) { _ in
                    self?.onTimer(durationProgressHandler)
                }
            }

            return recordingUrl
        } catch {
            stopRecording()
            return nil
        }
    }

    private func onTimer(_ durationProgressHandler: @escaping ProgressHandler) {
        guard let audioRecorder
        else { return }
        
        audioRecorder.updateMeters()
        let time = audioRecorder.currentTime
        
        let power: SIMD2<Float> = [
            audioRecorder.averagePower(forChannel: 0),
            audioRecorder.peakPower(forChannel: 0)
        ]
        
        // Power is from 0 db (max) to -60 db (roughly min).
        let normalizedPower = 1 - (max(power, -60) / 60 * -1)
        
        soundSamples.append(AudioSample(
            averagePower: CGFloat(normalizedPower.x),
            peakPower: CGFloat(normalizedPower.y)
        ))
        
        durationProgressHandler(time, soundSamples)
    }

    public func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        audioTimer?.invalidate()
        audioTimer = nil
    }

    private func fileExtension(for formatID: AudioFormatID) -> String? {
        switch formatID {
        case kAudioFormatMPEG4AAC:
            return ".aac"
        case kAudioFormatLinearPCM:
            return ".wav"
        case kAudioFormatMPEGLayer3:
            return ".mp3"
        case kAudioFormatAppleLossless:
            return ".m4a"
        case kAudioFormatOpus:
            return ".opus"
        case kAudioFormatAC3:
            return ".ac3"
        case kAudioFormatFLAC:
            return ".flac"
        case kAudioFormatAMR:
            return ".amr"
        case kAudioFormatMIDIStream:
            return ".midi"
        case kAudioFormatULaw:
            return ".ulaw"
        case kAudioFormatALaw:
            return ".alaw"
        case kAudioFormatAMR_WB:
            return ".awb"
        case kAudioFormatEnhancedAC3:
            return ".eac3"
        case kAudioFormatiLBC:
            return ".ilbc"
        default:
            return nil
        }
    }

}

public struct RecorderSettings : Codable,Hashable {
    var audioFormatID: AudioFormatID
    var sampleRate: CGFloat
    var numberOfChannels: Int
    var encoderBitRateKey: Int
    // pcm
    var linearPCMBitDepth: Int
    var linearPCMIsFloatKey: Bool
    var linearPCMIsBigEndianKey: Bool
    var linearPCMIsNonInterleaved: Bool

    public init(audioFormatID: AudioFormatID = kAudioFormatMPEG4AAC,
                sampleRate: CGFloat = 12000,
                numberOfChannels: Int = 1,
                encoderBitRateKey: Int = 128,
                linearPCMBitDepth: Int = 16,
                linearPCMIsFloatKey: Bool = false,
                linearPCMIsBigEndianKey: Bool = false,
                linearPCMIsNonInterleaved: Bool = false) {
        self.audioFormatID = audioFormatID
        self.sampleRate = sampleRate
        self.numberOfChannels = numberOfChannels
        self.encoderBitRateKey = encoderBitRateKey
        self.linearPCMBitDepth = linearPCMBitDepth
        self.linearPCMIsFloatKey = linearPCMIsFloatKey
        self.linearPCMIsBigEndianKey = linearPCMIsBigEndianKey
        self.linearPCMIsNonInterleaved = linearPCMIsNonInterleaved
    }
}

extension AVAudioSession {
    func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
