//
//  ViewController.swift
//  TodoListDemo2
//
//  Created by 诺诺诺诺诺 on 2022/10/21.
//

import UIKit
import CoreData

//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by 诺诺诺诺诺 on 2022/10/22.
//

class ViewController: UIViewController,UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    var NameData:[String] = ["eeee","lese","goto","todolist"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        config()
        view.addSubview(collectionView)
    }
    
    func config() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        
        collectionView.dataSource = self
        collectionView.register(MyCell.self
                                , forCellWithReuseIdentifier: "cell")
    }
    
    
    func createLayout() -> UICollectionViewCompositionalLayout {
            // 1
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .absolute(600))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let itemAnotherSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
        let itemAnother = NSCollectionLayoutItem(layoutSize: itemAnotherSize)
            // 2
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(600))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
            let groupAnotherSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
            
            let groupAnother = NSCollectionLayoutGroup.vertical(layoutSize: groupAnotherSize, repeatingSubitem: itemAnother, count: 2)

            // 3
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: .fixed(8), bottom: nil)
//
//        let groups = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [group,groupAnother])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let layout = UICollectionViewCompositionalLayout(section: section)
            return layout
    }

}

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let title = UILabel(frame: CGRectMake(20, 20, cell.bounds.size.width, 40))
        title.text = NameData[indexPath.row]
        cell.contentView.addSubview(title)
        
        if indexPath.row == 3 {
            let button = UIButton()
            button.frame = cell.contentView.frame
            button.addTarget(self, action: #selector(didTapButton), for: .touchDown)
            cell.contentView.addSubview(button)
        }
        
        cell.contentView.layer.cornerRadius = 10
        return cell
    }
    
    @objc func didTapButton() {
        print("byd")
        
        let rootVC = ListViewController()
        let navVC = UINavigationController(rootViewController: rootVC)
        
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated:  true)
    }
}

class MyCell: UICollectionViewCell {
    
    var label = UILabel()
    
    override init(frame: CGRect) {
       // print("a?a?")
        super.init(frame: frame)
        //label.text = "test"
        //contentView.addSubview(label)
        contentView.backgroundColor = UIColor.randomColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("ee")
    }
    
}

extension UIColor {
    //返回随机颜色
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}


class MyTableCell: UITableViewCell {
    var label = UILabel()
    var choosed = false
    
    
    
   
}


class ListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(MyTableCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    private var selectedIndexs: [Int] = []
    
    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 35
        button.backgroundColor = .systemBlue
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "To Do List"
        configuration()
       
        tableView.allowsMultipleSelection = true
        //deleteAllRecords()
        configFloatingButton()
        configLongPress()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: 50,
                                      y: view.frame.size.height - 150
                                        , width: 70, height: 70)
    }
    
    func configFloatingButton() {
        view.addSubview(floatingButton)
        floatingButton.addTarget(self, action: #selector(didTapAdd), for: .touchDown)
    }
    
    func configLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    func configuration() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        getAllItems()
        
//        let addButtom = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        let actionItem = UIBarButtonItem(systemItem: .action, primaryAction: nil, menu: createMenu())
        
        self.navigationItem.rightBarButtonItems = [actionItem,editButtonItem]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissSelf))
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel,handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    func turnTodarkView() {
        overrideUserInterfaceStyle = .dark
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                let alert = UIAlertController(title: "Edit Item", message: "Enter new item", preferredStyle: .alert)
                let item = models[indexPath.row]
                
                alert.addTextField(configurationHandler: nil)
                alert.textFields?.first?.text = item.name
                alert.addAction(UIAlertAction(title: "Submit", style: .cancel,handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                        return
                    }
                
                   self?.updateItem(item: item, newName: newName)}))
                
                self.present(alert, animated: true)
            }
        }
    }
    func turnTolightView() {
        overrideUserInterfaceStyle = .light
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true,completion: nil)
    }
    
}

extension ListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let item = models[indexPath.row]
//
//        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
//
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        sheet.addAction(UIAlertAction(title: "Edit", style: .default,handler: { _ in
//            let alert = UIAlertController(title: "Edit Item", message: "Enter new item", preferredStyle: .alert)
//
//            alert.addTextField(configurationHandler: nil)
//            alert.textFields?.first?.text = item.name
//            alert.addAction(UIAlertAction(title: "Submit", style: .cancel,handler: { [weak self] _ in
//                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
//                    return
//                }
//
//                self?.updateItem(item: item, newName: newName)
//            }))
//
//            self.present(alert, animated: true)
//
//        }))
//        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { [weak self] _ in
//            self?.deleteItem(item: item)
//        }))
//
//        present(sheet,animated: true)
        
     
        let cell = self.tableView.cellForRow(at: indexPath) as! MyTableCell
        if cell.choosed == false {
            cell.accessoryType = .checkmark
            cell.choosed = true
            cell.textLabel?.textColor = .gray
        }
        else {
            cell.choosed = false
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
        }
    }
    
    //设置哪些行可以编辑
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
       }
       
       // 设置单元格的编辑的样式
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return UITableViewCell.EditingStyle.delete
       }
       
       //设置点击删除之后的操作
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               // Delete the row from the data source
               self.deleteItem(item: self.models[indexPath.row])
               
           } else if editingStyle == .insert {
               // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
           }
       }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
}



//Core Data
extension ListViewController {
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrentCourse")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            //error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        print(name)
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
    
    func updateItem(item: ToDoListItem,newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
    
    func sortModelsByName() {
        do {
            let request = ToDoListItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            models = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("error")
        }
        
    }
    
    func sortModelsByDate() {
        do {
            let request = ToDoListItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            models = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("error")
        }
        
    }
}

extension ListViewController {
    func createMenu() -> UIMenu {
        // 第一个菜单
        let sortname = UIAction(title: "sortbyname", image: UIImage(systemName: "heart.fill")) { _ in
            self.sortModelsByName()
        }
                // 第二个菜单
        let darkMode = UIAction(title: "dark", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
                    print("share")
                self.turnTodarkView()
            }
        
        let lightMode = UIAction(title: "light", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
            print("share")
        self.turnTolightView()
    }
                // 第三个菜单
        let sortdate = UIAction(title: "sortbyDate", image: UIImage(systemName: "heart.fill")) { _ in
                    print("delete")
            self.sortModelsByDate()
        }

        let menuActions = [sortname, darkMode, sortdate,lightMode]
        let addNewMenu = UIMenu(
                   title: "",
                   children: menuActions)

        return addNewMenu
    }
}
