//
//  RecordWaveform.swift
//  
//
//  Created by Alisa Mylnikova on 14.03.2023.
//

import SwiftUI

struct RecordWaveformWithButtons: View {

    @Environment(\.chatTheme) private var theme

    @StateObject var recordPlayer = RecordingPlayer()

    // 160 is screen left-padding/right-padding and playButton's width.
    // ensure that the view does not exceed the screen, need to subtract
    // TODO: do not hardcode this value
    static let viewPadding: CGFloat = 160

    var recording: Recording

    var colorButton: Color
    var colorButtonBg: Color
    var colorWaveform: Color

    var duration: Int {
        max(Int((recordPlayer.secondsLeft != 0 ? recordPlayer.secondsLeft : recording.duration) - 0.5), 0)
    }

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if recordPlayer.playing {
                    theme.images.message.pauseAudio
                        .renderingMode(.template)
                } else {
                    theme.images.message.playAudio
                        .renderingMode(.template)
                }
            }
            .foregroundColor(colorButton)
            .viewSize(40)
            .circleBackground(colorButtonBg)
            .onTapGesture {
                recordPlayer.togglePlay(recording)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                RecordWaveformPlaying(samples: recording.waveformSamples, progress: recordPlayer.progress, color: colorWaveform, addExtraDots: false) { progress in
                    recordPlayer.seek(with: recording, to: progress)
                }
                Text(DateFormatter.timeString(duration))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundColor(colorWaveform)
            }
        }
        .onDisappear {
            recordPlayer.pause()
        }
    }
}

struct RecordWaveformPlaying: View {
    var samples: [CGFloat] // 0...1
    var progress: CGFloat
    var color: Color
    var addExtraDots: Bool
    var maxLength: CGFloat = 0.0

    let progressChangeHandler: (CGFloat) -> Void

    @State private var offset: CGSize = .zero

    private var adjustedSamples: [CGFloat] = []
    
    init(samples: [CGFloat],
         progress: CGFloat,
         color: Color,
         addExtraDots: Bool,
         progressChangeHandler: @escaping (CGFloat) -> Void) {
        self.samples = samples
        self.progress = progress
        self.color = color
        self.addExtraDots = addExtraDots
        self.progressChangeHandler = progressChangeHandler
        self.adjustedSamples = adjustedSamples(UIScreen.main.bounds.width)
        self.maxLength = max((RecordWaveform.spacing + RecordWaveform.width) * CGFloat(self.adjustedSamples.count) - RecordWaveform.spacing, 0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let adjusted = addExtraDots ? adjustedSamples(geometry.size.width) : adjustedSamples
                RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                    .foregroundColor(color.opacity(0.4))
                RecordWaveform(samples: adjusted, addExtraDots: addExtraDots)
                    .foregroundColor(color)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: maxLength * progress, height: 2 * geometry.size.height)
                    }
            }
            .frame(height: geometry.size.height)
        }
        .applyIf(!addExtraDots) {
            $0.frame(width: maxLength)
        }
        .frame(maxWidth: addExtraDots ? .infinity : maxLength)
        .fixedSize(horizontal: !addExtraDots, vertical: true)
        .gesture(addDragGesture)
    }

    private var addDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                let currentPosition = maxLength * progress
                // multiply by 0.5 so that the sliding will not be too sensitive
                var newPosition: CGFloat = currentPosition + offset.width * 0.5
                if offset.width > 0 {
                    newPosition = min(newPosition, maxLength)
                } else {
                    newPosition = max(newPosition, 0)
                }
                let newProgress = newPosition / maxLength
                progressChangeHandler(newProgress)
            }
    }

    func adjustedSamples(_ maxWidth: CGFloat) -> [CGFloat] {
        let maxSamples = Int((maxWidth - RecordWaveformWithButtons.viewPadding) / (RecordWaveform.width + RecordWaveform.spacing))
        let temp = samples
        
        if temp.count <= maxSamples {
            return temp
        }

        // use ceil to ensure that the adjusted.count will not be greater than maxSamples
        let ratio = Int(ceil( Double(temp.count) / Double(maxSamples) ))
        let adjusted = stride(from: 0, to: temp.count, by: ratio).map {
            temp[$0]
        }
        
        return adjusted
        
    }
}

public struct RecordWaveform: View {

    var samples: [CGFloat] // 0...1
    var addExtraDots: Bool
    var alignment: VerticalAlignment

    public static let spacing: CGFloat = 2
    public static let width: CGFloat = 2

    public init(samples: [CGFloat], addExtraDots: Bool, alignment: VerticalAlignment = .bottom) {
        self.samples = samples
        self.addExtraDots = addExtraDots
        self.alignment = alignment
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: alignment, spacing: RecordWaveform.spacing) {
                ForEach(Array(samples.enumerated()), id: \.offset) { _, s in
                    Capsule()
                        .frame(width: RecordWaveform.width, height: geometry.size.height * CGFloat(s))
                }
                let maxSampleCounts = Int((geometry.size.width) / (RecordWaveform.width + RecordWaveform.spacing))
                if addExtraDots && samples.count < maxSampleCounts {
                    ForEach(samples.count..<maxSampleCounts, id: \.self) { _ in
                        Capsule()
                            .viewSize(RecordWaveform.width)
                    }
                }
            }
            .frame(height: geometry.size.height)
        }
        .fixedSize(horizontal: !addExtraDots, vertical: false)
    }
}

#Preview {
    RecordWaveform(
        samples: (-50 ..< 50).map {
            1 / Double(max(1, abs($0)))
        },
        addExtraDots: true,
        alignment: .center)
}
