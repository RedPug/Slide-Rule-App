//
//  TipMenuView.swift
//  Slide Rule
//
//  Copyright (c) 2024 Rowan Richards
//
//  This file is part of Ultimate Slide Rule
//
//  Ultimate Slide Rule is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by the
//  Free Software Foundation, either version 3 of the License, or 
//  (at your option) any later version.
//
//  Ultimate Slide Rule is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
//  See the GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License along with this program.
//  If not, see <https://www.gnu.org/licenses/>.
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
