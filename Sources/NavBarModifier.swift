//
//  NavBarModifier.swift
//  PagerTabStripView
//
//  Copyright © 2022 Xmartlabs SRL. All rights reserved.
//

import SwiftUI

public extension View {
    func withPagerNavBar<T: Hashable, P: PagerStyle>(_ selection: Binding<T>,
                                                     style: P) -> some View {
        self
            .modifier(PagerNavBarModifier(selection: selection))
            .pagerTabStripViewStyle(style)
    }
}

public struct PagerNavBarModifier<SelectionType>: ViewModifier where SelectionType: Hashable {
    @Binding private var selection: SelectionType

    
    public init(selection: Binding<SelectionType>) {
        self._selection = selection
    }

    @MainActor
    public func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !style.placedInToolbar {
                if pagerBarPlacement == .top {
                    PagerNavBarWrapperView(selection: $selection)
                }
                content
                if pagerBarPlacement == .bottom {
                    PagerNavBarWrapperView(selection: $selection)
                }
            } else {
                content.toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        PagerNavBarWrapperView(selection: $selection)
                    }
                })
            }
        }
    }

    @Environment(\.pagerStyle) var style: PagerStyle
    @Environment(\.pagerBarPlacement) var pagerBarPlacement: PagerBarPlacementType
}

public struct PagerNavBarWrapperView<SelectionType>: View where SelectionType: Hashable {
    @Binding var selection: SelectionType

    public init(selection: Binding<SelectionType>) {
        self._selection = selection
    }

    
    @MainActor
    public var body: some View {
        switch style {
        case let barStyle as BarStyle:
            IndicatorBarView<SelectionType, AnyView>(selection: $selection, indicator: barStyle.indicatorView)
        case is SegmentedControlStyle:
            SegmentedNavBarView(selection: $selection)
        case let indicatorStyle as BarButtonStyle:
            if indicatorStyle.scrollable {
                ScrollableNavBarView(selection: $selection)
            } else {
                FixedSizeNavBarView(selection: $selection)
            }
        default:
            SegmentedNavBarView(selection: $selection)
        }
    }

    @Environment(\.pagerStyle) var style: PagerStyle
}
