//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(storeURL:  NSPersistentContainer
                                    .defaultDirectoryURL()
                                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            return NullStore()
        }

    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        let nav = UINavigationController()
        let rootVC = FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: { [baseURL, httpClient] image in
                let url = Self.imageCommentsEndpoint(baseURL: baseURL, image: image)

                let commentsVC = CommentsUIComposer.commentsComposedWith(
                    commentsLoader: {
                        Self.makeCommentsLoader(client: httpClient, url: url)
                    })
                Self.showImageComment(nav: nav, commentVC: commentsVC)
            }
        )
        nav.setViewControllers([rootVC], animated: false)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

    private static func showImageComment(nav: UINavigationController?, commentVC: UIViewController) {
        nav?.show(commentVC, sender: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }

    private func makeRemoteLoadMoreLoader(last: FeedImage) -> (AnyPublisher<Paginated<FeedImage>, Error>) {
        localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { localItems, newItems in
                (localItems + newItems, newItems.last)
            }.map(makePage)
            .caching(to: localFeedLoader)
    }

    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> (AnyPublisher<[FeedImage], Error>) {
        let url = FeedEndpoint.get(baseURL: baseURL, after: after)
        return httpClient
                .getPublisher(from: url)
                .tryMap(FeedItemMapper.map)
                .eraseToAnyPublisher()
    }

    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }

    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in { self.makeRemoteLoadMoreLoader(last: last)} } )
    }


    private static func imageCommentsEndpoint(baseURL: URL, image: FeedImage) -> URL {
        baseURL.appendingPathComponent("v1/image").appendingPathComponent(image.id.uuidString).appendingPathComponent("comments")
    }

    private static func makeCommentsLoader(client: HTTPClient, url: URL) -> AnyPublisher<[ImageComment], Error> {
        return client
            .getPublisher(from: url)
            .tryMap(ImageCommentsMapper.map)
            .eraseToAnyPublisher()

    }

    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        return localImageLoader
            .loadImagePublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImagePublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })


    }
}
