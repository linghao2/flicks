//
//  TopRatedViewController.swift
//  Flicks
//
//  Created by LING HAO on 4/2/17.
//  Copyright © 2017 CodePath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class TopRatedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var collectionView: UICollectionView!
    
    var searchBar = UISearchBar()
    
    var allFlicks = [Dictionary<String, AnyObject?>]()
    var flicks: [Dictionary<String, AnyObject?>]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.isHidden = false
        collectionView.isHidden = true
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        populateFlicks(nil)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        populateFlicks(refreshControl)
    }
    
    func populateFlicks(_ refreshControl: UIRefreshControl?) {
        if refreshControl == nil {
            // Don't show progress if there is a refreshControl already
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        self.errorView.isHidden = true
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let task :URLSessionDataTask = session.dataTask(with: url!) { (dataOrNil, response, error) in
            if error != nil {
                print("\(error)")
                self.errorView.isHidden = false
            } else {
                if let data = dataOrNil {
                    if let dict = try!
                        JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject?> {
                        
                        self.allFlicks = dict["results"] as! [Dictionary<String, AnyObject?>]
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                    }
                }
            }
            refreshControl?.endRefreshing()
            if refreshControl == nil {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let flicks = self.flicks {
            return  flicks.count
        } else {
            return allFlicks.count
        }
    }
    
    func getFlick(_ row: Int) -> Dictionary<String, AnyObject?> {
        if let flicks = self.flicks {
            return flicks[row]
        } else {
            return allFlicks[row]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlickCell") as! FlickTableViewCell
        cell.selectionStyle = .none
        let flick = getFlick(indexPath.row)
        cell.titleLabel.text = flick["title"] as? String
        cell.overviewLabel.text = flick["overview"] as? String
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        if let urlString = flick["poster_path"] as? String {
            let url = URL(string: posterBaseUrl + urlString)
            let urlRequest = URLRequest(url: url!)
            //cell.posterImageView.setImageWith(url!)
            cell.posterImageView.setImageWith(urlRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                if imageResponse != nil {
                    // image was not cached, fade in
                    cell.posterImageView.alpha = 0.0
                    cell.posterImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.posterImageView.alpha = 1.0
                    })
                } else {
                    // image was cached, just update the image
                    cell.posterImageView.image = image
                }
            }, failure: { (imageRequest, imageResponse, error) in
                print(error)
            })
        }
        return cell
    }

    // MARK: - Segment Control
    @IBAction func presentationChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex

        if index == 0 {
            tableView.isHidden = false
            collectionView.isHidden = true
        } else {
            tableView.isHidden = true
            collectionView.isHidden = false
        }

    }

    // MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        flicks = nil
        if searchText.isEmpty {
            flicks = nil
        } else {
            flicks = [Dictionary<String, AnyObject?>]()
            for flick in allFlicks {
                let title = flick["title"] as? String
                if indexOf(source: title!, target: searchText) != nil {
                    flicks?.append(flick)
                }
            }
        }
        tableView.reloadData()
    }
    
    func indexOf(source: String, target: String) -> Int? {
        let range = (source as NSString).range(of: target)
        
        guard range.toRange() != nil else {
            return nil
        }
        return range.location
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if allFlicks.count > 0 {
            return 3
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if allFlicks.count > 0 {
            return allFlicks.count / 3
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ITEM", for: indexPath) as! GridCollectionViewCell
        if allFlicks.count > 0 {
            let flick = getFlick(indexPath.section * 3 + indexPath.row
            )
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            if let urlString = flick["poster_path"] as? String {
                let url = URL(string: posterBaseUrl + urlString)
                let urlRequest = URLRequest(url: url!)
                //cell.posterImageView.setImageWith(url!)
                cell.gridImageView.setImageWith(urlRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) in
                    if imageResponse != nil {
                        // image was not cached, fade in
                        cell.gridImageView.alpha = 0.0
                        cell.gridImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.gridImageView.alpha = 1.0
                        })
                    } else {
                        // image was cached, just update the image
                        cell.gridImageView.image = image
                    }
                }, failure: { (imageRequest, imageResponse, error) in
                    print(error)
                })
            }

        }
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailViewController
        let cell = sender as! FlickTableViewCell
        vc.detailImage = cell.posterImageView.image
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            vc.flick = getFlick(indexPath.row)
        }
    }
    
}
