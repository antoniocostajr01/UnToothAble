//
//  UnToothAbleApp.swift
//  UnToothAble
//
//  Created by Antonio Costa on 13/03/26.
//

import SwiftUI
import GoogleMobileAds

@main
struct UnToothAbleApp: App {

    init() {
        MobileAds.shared.start()
        Task { @MainActor in
            RewardedAdManager.shared.preloadAd()
        }
        AssetLoader.preload()
    }

    var body: some Scene {
        WindowGroup {
            Root()
                .onAppear {
                    AudioManager.shared.playMusic(named: "backgroundSong.mp3")
                }
        }
    }
}
