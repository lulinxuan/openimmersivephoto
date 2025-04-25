//
//  VideoScreen.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 1/17/25.
//

import RealityKit
import Observation

/// Manages the sphere or half-sphere `Entity` onto which the video is projected.
@MainActor
public class PhotoScreen {
    /// The `ModelEntity` containing the sphere or half-sphere onto which the video is projected.
    public let entity: ModelEntity = ModelEntity()
    
    /// Public initializer for visibility.
    public init() {}
    
    /// Updates the video screen mesh with values from a VideoPlayer instance to resize it and start displaying its video media.
    /// - Parameters:
    ///   - videoPlayer: the VideoPlayer instance
    public func update(source videoPlayer: PhotoPlayer) {
        Task {
            await self.updateMesh(videoPlayer)
            withObservationTracking {
                _ = videoPlayer.horizontalFieldOfView
                _ = videoPlayer.verticalFieldOfView
                _ = videoPlayer.aspectRatio
                _ = videoPlayer.photoMaterial
            } onChange: {
                Task { @MainActor in
                    await self.updateMesh(videoPlayer)
                }
            }
        }
    }
    
    /// Programmatically generates the sphere or half-sphere entity with a VideoMaterial onto which the video will be projected.
    /// - Parameters:
    ///   - videoPlayer:the VideoPlayer instance
    private func updateMesh(_ videoPlayer: PhotoPlayer) async {
        let (mesh, transform) = await PhotoTools.makeVideoMesh(
            hFov: videoPlayer.horizontalFieldOfView,
            vFov: videoPlayer.verticalFieldOfView
        )
        
        let m = SimpleMaterial(color: .red, isMetallic: false)
        entity.name = "PhotoScreen"
        entity.model = ModelComponent(
            mesh: mesh,
            materials: [videoPlayer.photoMaterial]
        )
        entity.transform = transform
    }
}
