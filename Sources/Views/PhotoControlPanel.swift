//
//  ControlPanel.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/20/24.
//

import SwiftUI
import RealityKit

/// A simple horizontal view presenting the user with video playback controls.
public struct PhotoControlPanel: View {
    /// The singleton video player control interface.
    @Binding var videoPlayer: PhotoPlayer
    
    /// The callback to execute when the user closes the immersive player.
    let closeAction: (() -> Void)?
    
    /// Public initializer for visibility.
    /// - Parameters:
    ///   - videoPlayer: the singleton video player control interface.
    ///   - closeAction: the optional callback to execute when the user closes the immersive player.
    public init(videoPlayer: Binding<PhotoPlayer>, closeAction: (() -> Void)? = nil) {
        self._videoPlayer = videoPlayer
        self.closeAction = closeAction
    }
    
    public var body: some View {
        if videoPlayer.shouldShowControlPanel {
            VStack {
                HStack {
                    Button("", systemImage: "chevron.backward") {
                        closeAction?()
                    }
                    .controlSize(.extraLarge)
                    .tint(.clear)
                    .frame(width: 100)
                    
                    MediaInfo(videoPlayer: $videoPlayer)
                }
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}

/// A simple horizontal view with a dark background presenting video title, description, and a bitrate readout.
fileprivate struct MediaInfo: View {
    /// The singleton video player control interface.
    @Binding var videoPlayer: PhotoPlayer
    
    var body: some View {
        HStack {
                Spacer()
                VStack {
                    Text(videoPlayer.title.isEmpty ? "No Video Selected" : videoPlayer.title)
                        .font(.title)
                    
                    Text(videoPlayer.details)
                        .font(.headline)
                }
                Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
    }
}

//#Preview(windowStyle: .automatic, traits: .fixedLayout(width: 1200, height: 45)) {
//    ControlPanel(videoPlayer: .constant(VideoPlayer()))
//}

#Preview {
    RealityView { content, attachments in
        if let entity = attachments.entity(for: "ControlPanel") {
            content.add(entity)
        }
    } attachments: {
        Attachment(id: "ControlPanel") {
            PhotoControlPanel(videoPlayer: .constant(PhotoPlayer()))
        }
    }
}
