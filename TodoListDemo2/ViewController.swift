//
//  ViewController.swift
//  TodoListDemo2
//
//  Created by 诺诺诺诺诺 on 2022/10/21.
//

import UIKit

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

            // 2
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(600))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // 3
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: .fixed(8), bottom: nil)

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
            print("ni zai gan ma")
            cell.contentView.addSubview(button)
        }
        
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




class ListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "To Do List"
        configuration()
    }
    
    func configuration() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        getAllItems()
        
        let addButtom = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        let actionItem = UIBarButtonItem(systemItem: .action, primaryAction: nil, menu: createMenu())
        
        self.navigationItem.rightBarButtonItems = [addButtom,actionItem]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissSelf))
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
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default,handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Enter new item", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Submit", style: .cancel,handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                
                self?.updateItem(item: item, newName: newName)
            }))
            
            self.present(alert, animated: true)
        
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        
        present(sheet,animated: true)
    }
}



//Core Data
extension ListViewController {
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
