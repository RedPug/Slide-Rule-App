//
//  TipMenuView.swift
//  Slide Rule
//
//  Created by Rowan on 9/9/24.
//

import SwiftUI
import StoreKit

struct TipMenuView: View {
    @EnvironmentObject var store: TipStore
    
    var body: some View {
        VStack{
            Text("Every contribution helps drive the continued development of this app and is deeply appreciated.")
                .padding(.top)
                
            if store.items.count >= 4 {
                Grid{
                    GridRow{
                        TipItemView(item: store.items[0])
                        TipItemView(item: store.items[1])
                    }
                    GridRow{
                        TipItemView(item: store.items[2])
                        TipItemView(item: store.items[3])
                    }
                }
                .padding(16)
            }
        }
            .navigationTitle("Tips")
            .frame(maxWidth:.infinity, maxHeight:.infinity)
            .background(Color.theme.background)
    }
}
