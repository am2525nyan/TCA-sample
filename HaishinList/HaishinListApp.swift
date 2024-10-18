//
//  HaishinListApp.swift
//  HaishinList
//
//  Created by saki on 2024/10/08.
//

import SwiftUI

import ComposableArchitecture


@main
struct HaishinListApp: App {
    var body: some Scene {
        WindowGroup {
            ListItemView(
                store: Store(initialState: ListReducer.State()){
                ListReducer()
            }
                )
          
        }
    }
}
