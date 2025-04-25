//
//  VideoPlayer.swift
//  OpenImmersive
//
//  Created by Anthony Maës (Acute Immersive) on 9/14/24.
//

import SwiftUI
import AVFoundation
import RealityFoundation

/// Video Player Controller interfacing the underlying `AVPlayer`, exposing states and controls to the UI.
// @MainActor ensures properties are published on the main thread
// which is critical for using them in SwiftUI Views
@MainActor
@Observable
public class PhotoPlayer: Sendable {
    //MARK: Variables accessible to the UI
    /// The title of the current video (empty string if none).
    private(set) var title: String = ""
    /// A short description of the current video (empty string if none).
    private(set) var details: String = ""
    /// The aspect ratio of the current media (width / height).
    private(set) var aspectRatio: Float = 1.0
    /// The horizontal field of view for the current media
    private(set) var horizontalFieldOfView: Float = 180.0
    /// `true` if image has loaded from file/server
    private(set) var hasLoaded: Bool = false

    /// The vertical field of view for the current media
    public var verticalFieldOfView: Float {
        get {
            return max(0, min(180, self.horizontalFieldOfView / aspectRatio))
        }
    }
    /// `true` if the control panel should be visible to the user.
    private(set) var shouldShowControlPanel: Bool = true {
        didSet {
            if shouldShowControlPanel {
                restartControlPanelTask()
            }
        }
    }
    
    private var dismissControlPanelTask: Task<Void, Never>?
    
    public var photoMaterial: UnlitMaterial
    
    //MARK: Public methods
    /// Public initializer for visibility.
    public init(title: String = "", details: String = "", aspectRatio: Float? = nil, horizontalFieldOfView: Float? = nil, shouldShowControlPanel: Bool = true,dismissControlPanelTask: Task<Void, Never>? = nil) {
        self.title = title
        self.details = details
        if let aspectRatio { self.aspectRatio = aspectRatio }
        if let horizontalFieldOfView { self.horizontalFieldOfView = horizontalFieldOfView }
        self.shouldShowControlPanel = shouldShowControlPanel
        self.dismissControlPanelTask = dismissControlPanelTask
        
        self.photoMaterial = UnlitMaterial()
    }
    
    /// Instruct the UI to reveal the control panel.
    public func showControlPanel() {
        withAnimation {
            shouldShowControlPanel = true
        }
    }
    
    /// Instruct the UI to hide the control panel.
    public func hideControlPanel() {
        withAnimation {
            shouldShowControlPanel = false
        }
    }
    
    /// Instruct the UI to toggle the visibility of the control panel.
    public func toggleControlPanel() {
        withAnimation {
            shouldShowControlPanel.toggle()
        }
    }
    
    /// Load the indicated stream (will stop playback).
    /// - Parameters:
    ///   - stream: The model describing the stream.
    public func openStream(_ stream: PhotoModel) {
        title = stream.title
        details = stream.details
        
        self.applyPhotoMaterial(from: stream.url)
                
        // Set the video format to the forced field of view as provided by the StreamModel object, if available
        if let forceFieldOfView = stream.forceFieldOfView {
            // Detect resolution and field of view, if available
            horizontalFieldOfView = max(0, min(360, forceFieldOfView))
        } else {
            // Set the video format to the fallback field of view as provided by the StreamModel object,
            // then detect resolution and field of view encoded in the media, if available
            horizontalFieldOfView = max(0, min(360, stream.fallbackFieldOfView))
        }
    }
    
    func applyPhotoMaterial(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    self.title = "Cannot resolve image URL"
                    self.hasLoaded = true
                    return
                }
                let texture = try await TextureResource(image: image.cgImage!, options: .init(semantic: .color))
                self.photoMaterial.color = .init(texture: .init(texture))
                self.photoMaterial.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity(floatLiteral: 1))
                self.hasLoaded = true
            } catch {
                self.title = error.localizedDescription
                self.details = url.absoluteString
                self.hasLoaded = true
            }
        }
    }

    /// Restarts a task with a 10-second timer to auto-hide the control panel.
    private func restartControlPanelTask() {
        cancelControlPanelTask()
        dismissControlPanelTask = Task {
            try? await Task.sleep(for: .seconds(5))
            if !Task.isCancelled {
                hideControlPanel()
            }
        }
    }
    
    /// Cancels the current task to dismiss the control panel, if any.
    private func cancelControlPanelTask() {
        dismissControlPanelTask?.cancel()
        dismissControlPanelTask = nil
    }
}
