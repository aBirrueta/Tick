/*
 * ContentView.swift
 * 
 * PURPOSE: Main entry point for the app's user interface - serves as the root view.
 * USED IN: TickApp.swift - This is the primary view that iOS displays when the app launches.
 *          Acts as a simple container that loads the main countdown list interface.
 */

//

//  ContentView.swift
//  Tick
//
//  Created by Alejandro Birrueta on 6/14/25.
//

import SwiftUI

/// The root view of the app that serves as the entry point for the user interface
/// This view is instantiated by TickApp and displayed when the app launches
struct ContentView: View {
    // MARK: - Main View Body
    
    var body: some View {
        // Load the main countdown list interface
        // CountdownListView handles all the app's primary functionality:
        // - Displaying multiple countdowns
        // - Navigation to create/edit screens
        // - Live timer updates
        // - Data persistence
        CountdownListView()
    }
}

// MARK: - Preview Provider

#Preview {
    ContentView()
}
