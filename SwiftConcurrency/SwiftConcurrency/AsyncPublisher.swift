//
//  AsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/22.
//

import SwiftUI

/*
AsyncPublisher
*/

class AsyncPublihserDataManager {

    @Published var myData: [String] = []

    // addData()는 이미 비동기임에도 불구하고 task.sleep을 사용할 때는 async를 붙여줘?
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Melon")
    }
}

class AsyncPublisherViewModel: ObservableObject {

    // 항상 앱 main actor에 있어야 함
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublihserDataManager()

    init() {
        addSubscribers()
    }

    // AsyncPublisher -> publisher을 구독하는 것과 같음
    private func addSubscribers() {

        // 비동기 - 각 값이 통과될 때까지 비동기적으로 기다릴 것(await)
        // AsyncPublihserDataManager의 addData에서 publish 되면 사용 가능
        // case1.
        Task {
            for await value in manager.$myData.values {
                await MainActor.run {
//                    print(value)
                    self.dataArray = value
                }
            }
        }

        /*
         case2. Two는 절대 출력되지 않는다.
         for await 구문은 manager.$myData.values을 영원히 기다림
         myData publisher가 언제 멈출지 모르기 때문에?
         2개의 publisher 값들을 듣고 싶다면, Task 별도 관리
         */
//        Task {
//            await MainActor.run {
//                self.dataArray = ["ONE"]
//            }
//
//            for await value in manager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//            }
//
//            await MainActor.run {
//                self.dataArray = ["Two"]
//            }
//        }

        /*
         case3. Task 분리
         */
//        Task {
//            for await value in manager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//            }
//        }
//
//        Task {
//            for await value in manager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//            }
//        }

        // async sequence -> 다룰 예정
    }

    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisher: View {

    @StateObject private var viewModel = AsyncPublisherViewModel()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
    }
}

struct AsyncPublisher_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisher()
    }
}
