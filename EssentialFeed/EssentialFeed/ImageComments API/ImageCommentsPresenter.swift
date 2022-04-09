public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    let message: String
    let date: String
    let username: String
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }

}

public final class ImageCommentsPresenter {

    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
    }

    public static func map(
        _ comments: [ImageComment],
        _ currentDate: Date = Date(),
        _ calender: Calendar = .current,
        _ locale: Locale = .current
    ) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calender
        formatter.locale = locale
        return ImageCommentsViewModel(comments: comments.map {
            comment in
            ImageCommentViewModel(
                message: comment.message,
                date: formatter.localizedString(for: comment.createAt, relativeTo: currentDate),
                username: comment.username)
        })
    }
}
