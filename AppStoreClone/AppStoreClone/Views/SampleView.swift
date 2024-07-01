//
//  SampleView.swift
//  AppStoreClone
//
//  Created by Mustafa Bekirov on 30.06.2024.
//  Copyright © 2024 Mustafa Bekirov. All rights reserved.

import SwiftUI
import Observation

//@MainActor
//class SampleViewModel: ObservableObject {
//    @Published var count = 0
//    
//    func increaseOnBackgroundThread() {
//        Task {
//            count += 5
//        }
//    }
//}

@Observable
class ObservableSampleViewModel {
    var count = 0
    
    func increaseOnBackgroundThread() {
        Task {
            count += 5
        }
    }
}

struct SampleView: View {
    
//    @StateObject var vm = SampleViewModel()
    @State var vm = ObservableSampleViewModel()
    
    var body: some View {
        Button {
            vm.increaseOnBackgroundThread()
        } label: {
            Text("Increase by 1: \(vm.count)")
                .font(.largeTitle)
        }
    }
}

#Preview {
    SampleView()
}
