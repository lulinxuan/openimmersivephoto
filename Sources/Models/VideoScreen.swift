//
//  VideoScreen.swift
//  OpenImmersive
//
//  Created by Anthony Maës on 1/17/25.
//

import RealityKit
import Observation

@MainActor
@Observable
public class VideoScreen: Sendable {
    /// The `ModelEntity` containing the sphere or half-sphere onto which the video is projected.
    public let entity: ModelEntity = ModelEntity()
    
    /// Public initializer for visibility.
    public init() {}
    
    /// Attaches a VideoPlayer instance to the VideoScreen to resize it and start displaying its video media.
    /// - Parameters:
    ///   - videoPlayer:the VideoPlayer instance
    public func attachVideoPlayer(_ videoPlayer: VideoPlayer) {
        Task {
            await self.updateEntity(videoPlayer: videoPlayer)
            withObservationTracking {
                _ = videoPlayer.horizontalFieldOfView
                _ = videoPlayer.verticalFieldOfView
            } onChange: {
                Task { @MainActor in
                    await self.updateEntity(videoPlayer: videoPlayer)
                }
            }
        }
    }
    
    /// Programmatically generates the sphere or half-sphere entity with a VideoMaterial onto which the video will be projected.
    /// - Parameters:
    ///   - videoPlayer:the VideoPlayer instance
    private func updateEntity(videoPlayer: VideoPlayer) async {
        let (mesh, transform) = await VideoTools.makeVideoMesh(
            hFov: videoPlayer.horizontalFieldOfView,
            vFov: videoPlayer.verticalFieldOfView
        )
        entity.name = "VideoScreen"
        entity.model = ModelComponent(
            mesh: mesh,
            materials: [VideoMaterial(avPlayer: videoPlayer.player)]
        )
        entity.transform = transform
    }
}
