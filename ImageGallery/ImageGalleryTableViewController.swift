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
        imageGalleries = [
            [ImageGalleryModel(withName: "Trees"),
             ImageGalleryModel(withName: "Koalas"),
             ImageGalleryModel(withName: "Memes")]
            ,
            [ImageGalleryModel(withName: "Deleted")]]
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
            return imageGalleries.count > 0 ? "Recently Deleted" : nil
        default:
            return nil
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
