//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by zip520123 on 20/12/2021.
//

import UIKit

public extension UITableView {
    func dequeueCell<T: UITableViewCell>() -> T {
        let id = String(describing: T.self)
        let cell = dequeueReusableCell(withIdentifier: id)
        return cell as! T
    }
}
