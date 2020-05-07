//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Apple User on 04.05.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {

    var imageGalleries = [[ImageGalleryModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageGalleries = [[ImageGalleryModel(withName: "The animals observatory")]]
        let image1 = ImageModel(url: URL(string: "https://www.theanimalsobservatory.com/media/wysiwyg/pages/SpringSummer2020/cadaques889-copia.jpg")!, ascpectRatio: 1.35)
        let image2 = ImageModel(url: URL(string:"https://www.theanimalsobservatory.com/media/wysiwyg/pages/SpringSummer2020/Copia-de-cadaques171-copia.jpg")!, ascpectRatio: 1.35)
        let image3 = ImageModel(url: URL(string:"https://www.theanimalsobservatory.com/media/wysiwyg/pages/SpringSummer2020/Copia-de-cadaques918-copia.jpg")!, ascpectRatio: 0.75)
        let image4 = ImageModel(url: URL(string:"https://www.theanimalsobservatory.com/media/wysiwyg/pages/SpringSummer2020/Copia-de-cadaques820-copia.jpg")!, ascpectRatio: 0.75)
        let image5 = ImageModel(url: URL(string:"https://www.theanimalsobservatory.com/media/wysiwyg/pages/SpringSummer2020/Copia-de-cadaques951-copia.jpg")!, ascpectRatio: 0.75)
        imageGalleries[0][0].images = [image1,image2,image3,image4,image5]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if lastIndexPath != nil {
            tableView.selectRow(at: lastIndexPath!, animated: true, scrollPosition: .none)
        } else {
            selectRow(at: IndexPath(row: 0, section: 0))
        }
    }
    
    override func viewWillLayoutSubviews() {
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    @IBAction func addNewGallery(_ sender: UIBarButtonItem) {
        imageGalleries[0] += [ImageGalleryModel(withName: "Untitled")]
        tableView.insertRows(at: [IndexPath(row: imageGalleries[0].count-1, section: 0)], with: .fade)
        selectRow(at: IndexPath(row: imageGalleries[0].count-1, section: 0))
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return imageGalleries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleries[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Gallery Name Cell", for: indexPath)
            if let cell = cell as? IGTableViewCell {
                cell.textField.text = imageGalleries[indexPath.section][indexPath.row].name
                cell.resignationHandler = { [weak self, unowned cell] in
                    if let newGalleryName = cell.textField.text {
                        self?.imageGalleries[indexPath.section][indexPath.row].name = newGalleryName
                        self?.tableView.reloadData()
                        self?.selectRow(at: indexPath)
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Recently Deleted Cell", for: indexPath)
            cell.textLabel?.text = imageGalleries[indexPath.section][indexPath.row].name
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return imageGalleries[section].count > 0 ? "Recently Deleted" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let lastIndex = self.imageGalleries[0].count
            let undelete = UIContextualAction(
                style: .normal,
                title: "Undelete",
                handler: { (contextAction, sourceView, completionHandler) in
                    tableView.performBatchUpdates({
                        self.imageGalleries[0]
                            .insert(self.imageGalleries[1].remove(at: indexPath.row),at: lastIndex)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: lastIndex, section: 0)],
                                             with: .automatic)
                    }, completion: {finished in
                        self.selectRow(at: IndexPath(row: lastIndex, section: 0),after: 0.5)
                    })
                    completionHandler(true)
            })
            undelete.backgroundColor = UIColor.blue
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                if imageGalleries.count < 2 {
                    let removedRow = imageGalleries[0].remove(at: indexPath.row)
                    imageGalleries.insert([removedRow], at: 1)
                    tableView.reloadData()
                } else {
                tableView.performBatchUpdates({
                    imageGalleries[1].insert(imageGalleries[0].remove(at: indexPath.row), at: 0)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                }, completion: { finished in
                    if self.imageGalleries.count > 0, self.imageGalleries[0].count > 0 {
                        self.selectRow(at: IndexPath(row: 0, section: 0))
                    }
                })}
            case 1:
                tableView.performBatchUpdates({
                    imageGalleries[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }, completion: { finished in
                    if self.imageGalleries[0].count > 0 {
                        self.selectRow(at: IndexPath(row: 0, section: 0))
                    }
                })
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Image Gallery", sender: indexPath)
    }
    
    // MARK: - Navigation
    
    private var lastIndexPath: IndexPath?
    
    private var splitViewDetailCollectionController: ImageGalleryCollectionViewController? {
        let navigationController = splitViewController?.viewControllers.last as? UINavigationController
        return navigationController?.viewControllers.first as? ImageGalleryCollectionViewController
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Image Gallery":
                if  let indexPath = sender as? IndexPath,
                    let seguedToMVC = segue.destination.contents as? ImageGalleryCollectionViewController {
                    lastIndexPath = indexPath
                    if indexPath.section != 1 {
                        seguedToMVC.imageGallery = imageGalleries[indexPath.section][indexPath.row]
                        seguedToMVC.title = imageGalleries[indexPath.section][indexPath.row].name
                        seguedToMVC.collectionView.isUserInteractionEnabled = true
                    } else {
                        let ac = UIAlertController(title: nil, message: "You're trying to open Image Gallery from Recently Deleted section. Undelete it first please! Try to swipe from-left-to-right!", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default)
                        ac.addAction(ok)
                        present(ac, animated: true)
                    }
                    seguedToMVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                }
            default:
                break
            }
        }
    }
    
    private func selectRow(at indexPath: IndexPath,
                           after timeDelay:  TimeInterval = 0.0) {
        if tableView(self.tableView, numberOfRowsInSection: indexPath.section) >= indexPath.row {
            Timer.scheduledTimer(withTimeInterval: timeDelay, repeats: false, block: { (timer) in
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    self.tableView(self.tableView, didSelectRowAt: indexPath)
            })
        }
    }

}
