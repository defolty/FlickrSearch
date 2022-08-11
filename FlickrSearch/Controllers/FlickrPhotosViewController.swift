//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Nikita Nesporov on 03.08.2022.
//

import UIKit
 
final class FlickrPhotosViewController: UICollectionViewController {
    
    private let reuseIdentifier = "FlickrCell"
    
    private let sectionInsets = UIEdgeInsets(
        top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0
    )
    
    private var searches: [FlickrSearchResults] = []
    private let flickr = Flickr()
    private let itemsPerRow: CGFloat = 3
}

private extension FlickrPhotosViewController {
    ///# `photo(for:)` - метод, который позволяет получить конкретную фотографию,
    ///# связанную с `IndexPath` в представлении коллекции.
    func photo(for indexPath: IndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
}
 
extension FlickrPhotosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        ///# После добавления `ActivityView` используем класс-обертку Flickr для асинхронного поиска фотографий Flickr,
        ///# соответствующих заданному поисковому запросу.
        ///# Когда поиск завершается, вызываем блок завершения с набором объектов `FlickrPhoto` и любыми ошибками.
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        flickr.searchFlickr(for: text) { searchResults in
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                
                switch searchResults {
                case .failure(let error):
                    ///# Все ошибки записываются в консоль.
                    ///# Можем показать ошибки юзеру.
                    print("Error searching: \(error)")
                case .success(let results):
                    ///# Затем регистрируем результаты и добавляем их в начало массива поиска.
                    print("""
                    Found \(results.searchResults.count) \
                    matching \(results.searchTerm)
                    """)
                    self.searches.insert(results, at: 0)
                    ///# Обновляем ui, чтобы показать новые данные.
                    self.collectionView?.reloadData()
                }
            }
        } 
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosViewController {
    ///# На каждый раздел приходится один поиск, поэтому количество разделов равно количеству поисков.
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    ///# Количество элементов в разделе - это количество результатов поиска соответствующего поиска `FlickrSearch`
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
     
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        cell.imageView.image = flickrPhoto.thumbnail
        
        return cell
    }
}

extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
    ///# `collectionView(_:layout:sizeForItemAt:)` сообщает макету размер данной ячейки.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        ///# Здесь определяем общее количество места, занимаемое `padding`
        ///# У нас будет n + 1 равномерно распределенных мест, где n - количество элементов в ряду.
        ///# Можно взять размер пространства из левой вставки раздела.
        ///# Вычитание этого значения из ширины представления и деление на количество элементов
        ///# в ряду дает ширину для каждого элемента. Затем возвращаем размер в виде квадрата.
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    ///# `collectionView(_:layout: insetForSectionAt:)` возвращает расстояние между ячейками, заголовками и колонтитулами.
    ///# Значение хранится в константе.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    ///# Этот метод управляет расстоянием между каждой строкой в макете.
    ///# Хотим, чтобы это расстояние совпадало с отступом слева и справа.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
