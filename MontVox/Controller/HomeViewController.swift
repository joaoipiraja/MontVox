//
//  ViewController.swift
//  MontVox
//
//  Created by João Victor Ipirajá de Alencar on 11/10/22.
//

import UIKit





extension HomeViewController: HomeViewDataSource, HomeViewDelegate{
    func loadImage(on cell: CustomCollectionViewCell?, byId id: Int?) {
        guard let id = id else {return }

        API.fetchImage(route: .pictogram(id: id), by: id) { apiResponse in
            
            DispatchQueue.main.async {
                cell?.customView.imageView.image = apiResponse.result
            }
        }
    }
    
    func getCurrentObject(indexPath: IndexPath) -> Pictogram {
        return model[indexPath.row]
    }

    func getArrayCount() -> Int {
        return model.count
    }
    func getCurrentObjectString(indexPath: IndexPath) -> String {
        return model[indexPath.row].keywords.first?.keyword ?? ""
    }
}

class HomeViewController: UIViewController{
  
    let homeView = HomeView(frame: .zero)
    
    var model: Array<Pictogram> = Array<Pictogram>() {
        didSet {
            DispatchQueue.main.async {
                self.homeView.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = homeView
        
        homeView.dataSource = self
        homeView.delegate = self
        
        Task {
            await API.fetchData(arrayOf: Pictogram.self, route: API.Domain.Route.pictograms(all: .ptBR)){ apiResponse in
                           self.model = apiResponse.result ?? []
                           //print(self.model)
            }
        }
    }
}
