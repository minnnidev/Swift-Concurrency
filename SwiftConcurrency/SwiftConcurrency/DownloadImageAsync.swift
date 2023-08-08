//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by 김민 on 2023/08/08.
//

import SwiftUI

// async - await

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

    func downloadwithAsync() async throws -> UIImage? {
        /*
         func data(from url: URL, delegate: (URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse)
         ** throws! -> try 작성 필요
         장점1) weak self(약한 참조)를 추가할 필요가 없음
         장점2) completionHandeler 호출을 잊을 경우 앱에서 버그가 발생하지만, async await의 경우에는 return하는 것을 잊으면 그냥 컴파일 자체가 안 돼! -> 안전한 코드 작성
         */

        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
        /*
         이 메소드를 호출하면, 즉시 실행되지만 응답이 즉시 반환되지는 않음. 서버로 가서 해당 데이터를 가져와 반환됨
         await을 사용해서 응답을 기다리는 이 상태에서 일시 정지해야 할 수도 있음을 알림
         */
    }
}

class DownloadImageAsyncViewModel: ObservableObject {

    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()

//    func fetchImage() {
//        self.image = UIImage(systemName: "heart.fill")
//    }

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
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
