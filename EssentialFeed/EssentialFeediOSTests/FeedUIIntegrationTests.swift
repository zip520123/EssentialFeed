//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by zip520123 on 29/10/2021.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        let key = "FEED_VIEW_TITLE"
        
        XCTAssertEqual(sut.title, localized(key))
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests beview view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
                
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")
   
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when user initiate a load")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completes with error")
        
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 0)
        
        loader.completeFeedLoading(with: [image0], at: 0)
        
        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 1)
        
        assertThat(sut, with: image0, at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), 4)
        
        assertThat(sut, with: image0, at: 0)
        assertThat(sut, with: image1, at: 1)
        assertThat(sut, with: image2, at: 2)
        assertThat(sut, with: image3, at: 3)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, shouldRender: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        
        assertThat(sut, shouldRender: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visiable")
        
        sut.simulateFeedImageViewVisiable(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected first image URl request once first view becomes visiable")
        
        sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image URl request once second view also becomes visiable")
           
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisiableAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visiable")
        
        sut.simulateFeedImageViewNotVisiable(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first image URl request once first view becomes visiable")
        
        sut.simulateFeedImageViewNotVisiable(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second image URl request once second view also becomes visiable")
        
    }
    
    func test_feedImageViewLoadingIndicator_isVisiableWhileLoadingImage() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(view0?.isShowingImageIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageIndicator, true, "Expected loading indicator for secend view while loading first image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageIndicator, false, "Expected no loading indicator for secend view once second image loading complete with error")
        
    }
    
    func test_feedImageView_renderImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(),makeImage() ], at: 0)
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(with: .red).pngData()!
        loader.completeImageLoading(with: imageData0 ,at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image view complete successfully")
        
        let imageData1 = UIImage.make(with: .blue).pngData()!
        loader.completeImageLoading(with: imageData1 ,at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading successfully")
    }
    
    
    func test_feedImageViewRetryButton_isVisiableOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage(),makeImage() ], at: 0)
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData0 = UIImage.make(with: .red).pngData()!
        loader.completeImageLoading(with: imageData0 ,at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view once first image view loading completes successfully")
        
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second view image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second view image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewVisiable(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false)
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        
        XCTAssertEqual(view?.isShowingRetryAction, true)
        
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        let view0 = sut.simulateFeedImageViewVisiable(at: 0)
        let view1 = sut.simulateFeedImageViewVisiable(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL])
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL])
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisiable(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisiable(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image URL request once second image is near visible")
        
        
    }
    
    func test_feedImageView_cancelsImageURLloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisiable(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisiable(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
        
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewNotVisiable(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visiable anymore")
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainTread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadImageDataCompletion_dispatchsFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        sut.simulateFeedImageViewVisiable(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            
            loader.completeImageLoading(with: self.anyImageData(), at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }

    func test_loadFail_displayErrorMsg() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeFeedLoadingWithError()
        XCTAssertTrue(sut.errorViewIsVisible())
    }

    func test_tapErrorMsg_hideErrorView() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError()
        sut.simulateTapOnErrorMessage()
        XCTAssertFalse(sut.errorViewIsVisible())
    }

    func test_simulatePullRequest_hideErrorView() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoadingWithError()
        sut.simulateUserInitiatedFeedReload()
        XCTAssertFalse(sut.errorViewIsVisible())
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    fileprivate func anyImageData() -> Data {
        return UIImage.make(with: .red).pngData()!
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, shouldRender images: [FeedImage],  file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageView(), images.count, "image count != numberOfRenderedFeedImageView")
        images.enumerated().forEach { assertThat(sut, with: $1, at: $0) }
    }
    
    private func assertThat(_ sut: FeedViewController, with image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view, file: file, line: line)
        let shouldShowLocation = image.location != nil
        XCTAssertEqual(view?.isShowingLocation, shouldShowLocation, "Expected show location, got \(shouldShowLocation) instead at \(index)", file: file, line: line)
        XCTAssertEqual(view?.locationText, image.location, "Expected location text \(String(describing: image.location)), got \(String(describing: view?.locationText)) instead at index: \(index)" , file: file, line: line)
        XCTAssertEqual(view?.descriptionText, image.description, "Expected description text \(String(describing: image.description)), got \(String(describing: view?.descriptionText)) instead at index: \(index)" ,file: file, line: line)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        var loadFeedCallCount: Int { feedRequests.count }
        private(set) var feedRequests = [(FeedLoader.Result)->Void]()
        
        // MARK: FeedLoader
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "Any Error", code: 0, userInfo: nil)
            feedRequests[index](.failure(error))
        }
        
        // MARK: FeedImageDataLoader
        
        var loadedImageURLs: [URL] {
            imageRequest.map {$0.url}
        }
        
        private(set) var cancelledImageURLs = [URL]()
        private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result)-> Void)]()
        struct LoaderSpyTask: FeedImageDataLoaderTask {
            let cancelCompletion: (() -> Void)?
            
            func cancel() {
                cancelCompletion?()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result)-> Void) -> FeedImageDataLoaderTask {
            
            imageRequest.append((url, completion))
            return LoaderSpyTask(cancelCompletion: { [weak self] in
                self?.cancelledImageURLs.append(url)
            })
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequest[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "Any Error", code: 0)
            imageRequest[index].completion(.failure(error))
        }
    }
    
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func simulateTapOnErrorMessage() {
        errorView.button.simulateTap()
    }
    
    @discardableResult
    func simulateFeedImageViewVisiable(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisiable(at row: Int) -> FeedImageCell? {
        let cell = simulateFeedImageViewVisiable(at: row)
        let index = IndexPath(row: row, section: feedImageSection)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: index)
        return cell
    }
    
    func simulateFeedImageViewNearVisiable(at row: Int) {
        let index = IndexPath(row: row, section: feedImageSection)
        
        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisiable(at row: Int) {
        simulateFeedImageViewNearVisiable(at: row)
        let indexPath = IndexPath(row: row, section: feedImageSection)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedFeedImageView() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        0
    }
}

private extension FeedImageCell {
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var descriptionText: String? {
        descripitonLabel.text
    }
    
    var isShowingImageIndicator: Bool {
        feedimageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
}

private extension UIButton {
    func simulateTap() {
//        sendActions(for: .touchUpInside)
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ (selector) in
                let selector1 = Selector(selector)
                (target as NSObject).perform(selector1)
            })
        })
        
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ (target) in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (selector) in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}

private extension UIImage {
    static func make(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
