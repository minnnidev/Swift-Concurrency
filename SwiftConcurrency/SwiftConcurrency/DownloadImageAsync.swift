//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/08.
//

import SwiftUI
import Combine

// async await

class DownloadImageAsyncImageLoader {

    let url = URL(string: "https://picsum.photos/200")!

    func handleResponse(data: Data? , response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
            }
        return image
    }

    // 1. escaping closure 이용하기
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        /*
         URLSession.shared.dataTask(with: url)은 downloadWithEscaping 함수를 호출했을 때 실행되지만, 그 다음의 클로저는 서버로부터 데이터가 왔을 때 실행된다.
         */
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }

    // 2. combine 이용하기
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }

    // 3. async await 이용하기
    /*
     장점1. 가독성
     장점2. do-catch, try, throw로 간편하게 오류 처리 및 결과 반환
     장점3. 메모리 참조 관리하지 않아도 됨. weak self 안 씀.
     장점4. completionHandeler 호출을 잊을 경우 앱에서 버그가 발생하지만, async await의 경우에는 return하는 것을 잊으면 그냥 컴파일 자체가 안 돼! -> 안전한 코드 작성 가능
     */
    func downloadwithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            /*
             func data(from url: URL, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse)
             - data 메소드 자체도 오류를 던지므로, try 작성 필요
             - 이 메소드를 호출하면, 즉시 실행되지만 응답이 즉시 반환되지는 않음. 서버로 가서 해당 데이터를 가져와 반환됨.
             - await을 사용해서 응답을 기다리는 이 상태에서 일시 정지해야 할 수도 있음을 알림
             */
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {

    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()

    func fetchFirstImage() {
        self.image = UIImage(systemName: "heart.fill")
    }

    func fetchImageWithEscaping() {
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }

    func fetchImageWithCombine() {
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellables)
    }

    func fetchImage() async {
        let image = try? await loader.downloadwithAsync()

        // async에서는 메인 스레드로 전환하기 위해 MainActor을 사용함
        // 메인 스레드로 가기 위해 중단되어야 할 수 있으므로, await 키워드 필요
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {

    @StateObject private var viewModel = DownloadImageAsyncViewModel()

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
//            viewModel.fetchFirstImage()
//            viewModel.fetchImageWithEscaping()
//            viewModel.fetchImageWithCombine()
            Task { // 비동기 처리를 위해서는 Task에 진입해야 한다. Task는 다음 강의에서 알아볼 것.
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
