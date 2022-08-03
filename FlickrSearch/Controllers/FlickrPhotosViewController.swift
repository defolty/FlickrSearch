//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Nikita Nesporov on 03.08.2022.
//

import UIKit
// 69621e7f8cf564b6c00d6e93264243f1
// 45c4ebff0d031ff0
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
    ///# `photo(for:)` - это удобный метод, который позволяет получить конкретную фотографию,
    ///# связанную с `IndexPath` в представлении коллекции.
    ///# Вы будете часто обращаться к фотографии для определенного `IndexPath`, и вам не захочется повторять код.
    func photo(for indexPath: IndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
}

///# Hold the text field delegate methods:
extension FlickrPhotosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return true }
        
        ///# После добавления `ActivityView` вы используете класс-обертку Flickr для асинхронного поиска фотографий Flickr,
        ///#  соответствующих заданному поисковому запросу.
        ///# Когда поиск завершается, вы вызываете блок завершения с набором объектов `FlickrPhoto` и любыми ошибками.
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
                    ///# Очевидно, что в производственном приложении вы захотите показать пользователю эти ошибки.
                    print("Error searching: \(error)")
                case .success(let results):
                    ///# Затем вы регистрируете результаты и добавляете их в начало массива поиска.
                    print("""
                    Found \(results.searchResults.count) \
                    matching \(results.searchTerm)
                    """)
                    self.searches.insert(results, at: 0)
                    ///# Наконец, вы обновляете пользовательский интерфейс, чтобы показать новые данные.
                    ///# Вы используете функцию `reloadData()`, которая работает так же, как и в табличном представлении
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
    
    ///# Это метод-заполнитель, возвращающий пустую ячейку.
    ///# Вы заполните ее позже.
    ///# Обратите внимание, что представления коллекции требуют регистрации ячейки с идентификатором повторного использования.
    ///# В противном случае возникнет ошибка времени выполнения`(runtime error)`
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .black
        
        return cell
    }
}

extension FlickrPhotosViewController: UICollectionViewDelegateFlowLayout {
    ///# `collectionView(_:layout:sizeForItemAt:)` сообщает макету размер данной ячейки.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        ///# Здесь вы определяете общее количество места, занимаемое `padding`
        ///# У вас будет n + 1 равномерно распределенных мест, где n - количество элементов в ряду.
        ///# Вы можете взять размер пространства из левой вставки раздела.
        ///# Вычитание этого значения из ширины представления и деление на количество элементов
        ///# в ряду дает ширину для каждого элемента. Затем вы возвращаете размер в виде квадрата.
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
    ///# Вы хотите, чтобы это расстояние совпадало с отступом слева и справа.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
