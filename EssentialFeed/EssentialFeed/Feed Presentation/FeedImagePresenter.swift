public final class FeedImagePresenter {

    public static func map(_ image: FeedImage) -> FeedImageCellViewModel {
        FeedImageCellViewModel(
            description: image.description,
            location: image.location)
    }
}
