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
        if UserDefaults.standard.object(forKey: "musicEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "musicEnabled")
        }

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
                    if UserDefaults.standard.bool(forKey: "musicEnabled") {
                        AudioManager.shared.playMusic(named: "backgroundSong.mp3")
                    }
                }
        }
    }
}
