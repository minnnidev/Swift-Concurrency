//
//  Actors.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/20.
//

import SwiftUI

/*
클래스는 thread-safe하지 않다.
여러 스레드가 동시에 동일한 객체에 접근하면, 앱은 심각한 문제에 부딪힐 수도 있음
클래스를 thread-safe하게 만드려면?

1. How was this problem solved prior to actors? actor 이전에는 그 문제를 어떻게 해결하였는가?
    1-1. 기본적으로 클래스가 동일한 스레드나 큐에서만 실행되도록 해 놓기
    Actor가 없을 때는 큐로 만들었음
2. What is the problem that actor are solving? actor는 어떤 문제를 해결하는가?
    2-2. Actor는 lock을 자동으로 수행해 준다 + completionHandler 사용 필요없
3. Actors can solve the problem
*/

//class MyDataManager {
//
//    static let instance = MyDataManager()
//
//    private init() { }
//
//    var data: [String] = []
//
//    func getRandomData() -> String? {
//        data.append(UUID().uuidString)
//        print(Thread.current)
//        return data.randomElement()
//    }
//}

// 1-1. thread-safe를 위해 기본적으로 클래스가 동일한 스레드나 큐에서만 실행되도록 해 놓기
class MyDataManager {

    static let instance = MyDataManager()

    private init() { }

    var data: [String] = []
    private let lock = DispatchQueue(label: "com.SwiftConcurrency.MyDataManager")

    func getRandomData(completionHander: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHander(self.data.randomElement())
        }
    }
}

/*
2. actor 사용하기
actor 안의 내부에 접근하고 싶을 때는 await이 필요
actor 안의 모든 코드는 isolated 있기 때문
isolated 이라, thread-safe임
*/
actor MyActorDataManager {

    static let instance = MyActorDataManager()

    private init() { }

    var data: [String] = []

    nonisolated let myRandomText = "something"

    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }

    /*
     if. 드문 경우이긴 하지만, actor 안의 코드가 isolated이길 원하지 않는다면?
     await을 할 필요가 없다면? nonisolated 사용하기

     nonisolated 함수가 isolated 함수에 접근할 수는 없음
    */
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
}

struct HomeView: View {

    @State private var text: String = ""
//    let manager = MyDataManager.instance
    let manager = MyActorDataManager.instance
    let timer = Timer.publish(every: 0.01, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()

    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
                .ignoresSafeArea()

            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            // main thread에서 작동한다
//            if let data = manager.getRandomData() {
//                text = data
//            }
//            DispatchQueue.global(qos: .background).async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }

            // 1-1.
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }

            // 2.
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
        .onAppear {
            let newString = manager.getSavedData()
            let myRandomText = manager.myRandomText
        }
    }
}

struct BrowseView: View {

    @State private var text: String = ""
//    let manager = MyDataManager.instance
    let manager = MyActorDataManager.instance
    let timer = Timer.publish(every: 0.1, tolerance: nil, on: .main, in: .common, options: nil).autoconnect()

    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8)
                .ignoresSafeArea()

            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            // main thread에서 작동한다
//            DispatchQueue.global(qos: .default).async {
//                if let data = manager.getRandomData() {
//                    DispatchQueue.main.async {
//                        self.text = data
//                    }
//                }
//            }

            // 1-1.
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }

            // 2.
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct Actors: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct Actors_Previews: PreviewProvider {
    static var previews: some View {
        Actors()
    }
}
